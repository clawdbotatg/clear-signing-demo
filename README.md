# Clear Signing Demo

An iPhone app that shows what clear signing is. It looks like a hardware wallet asking you to sign.

- **▲ ▼** switch the screen between **clear** (what the transaction does, in words) and **blind** (the raw bytes).
- **Green** or **red** moves to the next transaction. Nothing is signed or sent.

11 example transactions, in `ClearSigningDemo/transactions.json`. Half are fine, half would take your money.
In blind mode they all look the same.

| | What it does | Data |
|-|-|-|
| 1 | Send 25 USDC | made here |
| 2 | Uniswap: swap 0.4805 ETH for USDC | real mainnet tx 0x40d62b80… |
| 3 | Approve unlimited USDC to an unknown address | made here |
| 4 | Aave: repay 997 USDC | ERC-7730 registry test |
| 5 | Permit2 signature: unlimited USDC, never expires | made here (EIP-712 hashes) |
| 6 | Lido: wrap 1 stETH | ERC-7730 registry test |
| 7 | Bored Apes: approve all to an unknown address | made here |
| 8 | Safe: add an owner | made here |
| 9 | Uniswap swap that pays someone else | real mainnet tx 0xb813cd40… |
| 10 | Safe: turn on an unknown module | made here |
| 11 | Approve 100 USDC to Permit2 | made here |

The clear screens follow what a [wedgie](https://wedgie.dev/clear) shows for the same calls.

## Build

```
brew install xcodegen
xcodegen generate
open ClearSigningDemo.xcodeproj
```

Team XX7QP5899Z, bundle id `dev.wedgie.clearsigningdemo`. Screenshots: launch with `-index 3 -blind YES`.
Icon: `tools/icon.svg` → `Assets.xcassets/AppIcon.appiconset/icon.png`.

MIT.
