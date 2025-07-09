# Certora Tricks

This is a collection of examples highlighting non-obvious issues you might encounter while working with Certora, along with ways to fix them. Feel free to submit a PR with your own tricks!

## Overflow

Let's look at a [simple rule](certora/specs/Overflow.spec#19) where we check that after a deposit, the asset balance of the `Vault` has increased. This seems like a valid rule, but if we run it, the rule gets violated.

This happens because the `balanceOf()` function returns a value of type `uint256`, which can overflow. For example, if the balance is `2^256 - 1` and we add `1`, it wraps around to `0`.

To prevent this, we should define the [totalSupplyIsSumOfBalances](certora/specs/dependencies/erc20.spec#34) invariant and [use it](certora/specs/Overflow.spec#40) in our rules via the [requireInvariant](https://docs.certora.com/en/latest/docs/user-guide/patterns/require-invariants.html) statement. Here's how it works:

1. **Invariant constrains the state**: `totalSupply() == sumOfBalances`
2. **`sumOfBalances` is a `mathint`**: It cannot overflow
3. **`totalSupply()` is constrained**: It must equal the `mathint` value
4. **All balances are constrained**: By the `Sload` hook, each balance is less than or equal to the total sum
5. **No overflow is possible**: The system cannot reach overflow states

Now it works as expected 🙂

