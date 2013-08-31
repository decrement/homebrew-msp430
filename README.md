homebrew-msp430
===============

This repository contains MSP430 related [Homebrew][] formulae.

Available Formulae
------------------
- mspgcc LTS 20120406 (formula installs everything under one keg)
  - binutils 2.21.1a
  - gcc 4.6.3
  - gdb 7.2a
  - msp430mcu 20120406
  - msp430-libc 20120224

Installing homebrew-msp430 Formulae
-----------------------------------
Just `brew tap decrement/msp430` and then `brew install <formula>`.

To install the entire MSPGCC toolchain, do:
`brew install mspgcc`

You can also install via URL:

```
brew install https://raw.github.com/decrement/homebrew-msp430/master/<formula>.rb
```

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[Homebrew]:https://github.com/mxcl/homebrew
[wiki]:https://github.com/mxcl/homebrew/wiki
