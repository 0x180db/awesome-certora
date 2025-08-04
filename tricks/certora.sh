#!/bin/bash

set -e

PROJECT_ROOT="certora"
SPECS_DIR="$PROJECT_ROOT/specs/base"
CONF_DIR="$PROJECT_ROOT/confs"
HARNESS_DIR="$PROJECT_ROOT/harnesses"

function init_project() {
    mkdir -p "$PROJECT_ROOT/specs/base"
    mkdir -p "$PROJECT_ROOT/specs/dependencies"
    mkdir -p "$CONF_DIR"
    mkdir -p "$HARNESS_DIR"
    echo "Certora project structure initialized."
}

function add_contract() {
    CONTRACT_PATH="$1"
    FLAG="$2"

    if [ -z "$CONTRACT_PATH" ]; then
        echo "Usage: $0 add path/to/Contract.sol [--methods]"
        exit 1
    fi

    if [ ! -f "$CONTRACT_PATH" ]; then
        echo "Contract file not found: $CONTRACT_PATH"
        exit 1
    fi

    CONTRACT_NAME="$(basename "$CONTRACT_PATH" .sol)"
    HARNESS_NAME="${CONTRACT_NAME}Harness"
    HARNESS_FILE="$HARNESS_DIR/${HARNESS_NAME}.sol"
    SPEC_FILE="$SPECS_DIR/${CONTRACT_NAME}.spec"

    # Extract pragma
    PRAGMA=$(grep -oE '^pragma solidity [^;]+;' "$CONTRACT_PATH" | head -n 1)

    # Extract constructor arguments
    CONSTRUCTOR=$(forge inspect "$CONTRACT_PATH" abi --json | jq -r '
        map(select(.type == "constructor"))[0] // empty
    ')

    if [ -n "$CONSTRUCTOR" ]; then
        PARAM_LIST=$(echo "$CONSTRUCTOR" | jq -r '.inputs | map("\(.type) " + .name) | join(", ")')
        ARG_LIST=$(echo "$CONSTRUCTOR" | jq -r '.inputs | map(.name) | join(", ")')
    else
        PARAM_LIST=""
        ARG_LIST=""
    fi

    # Create Harness
    if [ -f "$HARNESS_FILE" ]; then
        echo "Warning: Harness file already exists at $HARNESS_FILE"
        read -p "This will overwrite any manual changes. Continue? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    cat > "$HARNESS_FILE" <<EOF
// SPDX-License-Identifier: MIT

$PRAGMA

import "../../$CONTRACT_PATH";

contract $HARNESS_NAME is $CONTRACT_NAME {
    constructor($PARAM_LIST) $CONTRACT_NAME($ARG_LIST) { }
}
EOF
    echo "Created harness: $HARNESS_FILE"

    # Create .spec file with optional method block
    if [ -f "$SPEC_FILE" ]; then
        echo "Warning: Spec file already exists at $SPEC_FILE"
        read -p "This will overwrite any manual changes. Continue? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    echo "using ${HARNESS_NAME} as _${CONTRACT_NAME};" > "$SPEC_FILE"
    echo "" >> "$SPEC_FILE"

    if [ "$FLAG" = "--methods" ]; then
        echo "/////////////////// METHODS ///////////////////////" >> "$SPEC_FILE"
        echo "methods {" >> "$SPEC_FILE"

        # Generate method declarations (non-view, including getters)
        forge inspect "$CONTRACT_PATH" abi --json | jq -r --arg name "$CONTRACT_NAME" '
          .[] |
          select(.type == "function" and (.stateMutability != "view" and .stateMutability != "pure")) |
          "    // function _" + $name + "." + .name + "(" +
            (.inputs | map(.type) | join(", ")) +
          ") external" +
          (if .outputs and (.outputs | length > 0)
           then " returns (" + (.outputs | map(.type) | join(", ")) + ")"
           else ""
           end) +
          " envfree;"
        ' >> "$SPEC_FILE"
        echo "}" >> "$SPEC_FILE"
        echo "" >> "$SPEC_FILE"
        echo "Filled method block for: $CONTRACT_NAME"
    else
        echo "/////////////////// METHODS ///////////////////////" >> "$SPEC_FILE"
        echo "methods {" >> "$SPEC_FILE"
        echo "    // Add methods here" >> "$SPEC_FILE"
        echo "}" >> "$SPEC_FILE"
    fi

    cat >> "$SPEC_FILE" <<EOF

///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////

///////////////// PROPERTIES //////////////////////
EOF

    echo "Created spec template: $SPEC_FILE"
}

function create_spec_and_conf() {
    CONTRACT_PATH="$1"
    FLAG="$2"

    if [ -z "$CONTRACT_PATH" ]; then
        echo "Usage: $0 spec path/to/Contract.sol [--dispatcher]"
        exit 1
    fi

    if [ ! -f "$CONTRACT_PATH" ]; then
        echo "Contract file not found: $CONTRACT_PATH"
        exit 1
    fi

    CONTRACT_NAME="$(basename "$CONTRACT_PATH" .sol)"
    HARNESS_NAME="${CONTRACT_NAME}Harness"
    SPEC_FILE="certora/specs/${CONTRACT_NAME}.spec"
    CONF_FILE="certora/confs/${CONTRACT_NAME}.conf.json"

    # Base spec
    #
    SPEC_FILE="certora/specs/${CONTRACT_NAME}.spec"

    if [ -f "$SPEC_FILE" ]; then
        echo "Warning: Spec file already exists at $SPEC_FILE"
        read -p "This will overwrite any manual changes. Continue? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    echo "import \"./base/${CONTRACT_NAME}.spec\";" > "$SPEC_FILE"
    echo "" >> "$SPEC_FILE"
    echo "/////////////////// METHODS ///////////////////////" >> "$SPEC_FILE"
    echo "methods {" >> "$SPEC_FILE"

    solc --combined-json ast "$CONTRACT_PATH" | jq -r '
      .sources[].AST.nodes[]
      | .. | select(.nodeType? == "FunctionCall")
      | select(.expression.nodeType == "MemberAccess")
      | select(.expression.expression.nodeType == "Identifier")
      | select(.expression.expression.name != "this")
      | {
          name: .expression.memberName,
          args: (.arguments // [] | map(.typeDescriptions.typeString | gsub("struct [^ ]+ "; "") | gsub("contract [^ ]+ "; ""))),
        }
      | "    function _.\(.name)(\(.args | join(", "))) external => DISPATCHER(true);"
        ' | sort -u >> "$SPEC_FILE"

    echo "}" >> "$SPEC_FILE"
    cat >> "$SPEC_FILE" <<EOF

///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////

///////////////// PROPERTIES //////////////////////
EOF

    echo "Created main spec: $SPEC_FILE"

    # Config generation
    if [ -f "$CONF_FILE" ]; then
        echo "Warning: Conf file already exists at $CONF_FILE"
        read -p "Overwrite it as well? [y/N]: " confirm_conf
        if [[ ! "$confirm_conf" =~ ^[Yy]$ ]]; then
            echo "Skipping config file creation."
            return
        fi
    fi

    cat > "$CONF_FILE" <<EOF
{
    "files": [
        "certora/harness/${HARNESS_NAME}.sol"
    ],
    "link": [
        "${HARNESS_NAME}:_baseToken=ERC20Mock"
    ],
    "verify": "${HARNESS_NAME}:certora/specs/${CONTRACT_NAME}.spec",
    "optimistic_loop": true,
    "msg": "${HARNESS_NAME}",
    "parametric_contracts": ["${HARNESS_NAME}"]
}
EOF

    echo "Created config: $CONF_FILE"
}

# Main command parsing
case "$1" in
    init)
        init_project
        ;;
    add)
        shift
        add_contract "$1" "$2"
        ;;
    spec)
        shift
        create_spec_and_conf "$1" "$2"
        ;;
    *)
        echo "Certora Project Bootstrap — by 0x180db"
        echo "Usage: $0 [init | add path/to/Contract.sol [--methods] | spec path/to/Contract.sol [--dispatcher]]"
        exit 1
        ;;
esac

