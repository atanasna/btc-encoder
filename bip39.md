# Creating a BIP39 mnemonic 100% by hand (almost)
This document shows how we can create Bitcoin wallet mnemonic seeds by hand in a provably secure way. It follows
the [BIP-39 specification][1]. The steps are straight forward, and we'll go into each of them in detail with this doc.

[1]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki

The steps are as follows:

* Generate cryptographically secure bits
  * Divide into 11-bit bytes
  * Convert each 11-bit word to decimal
  * Locate its index in the BIP-39 word list for your language
* Hash the original bitstring with SHA-256
  * Convert the most significant byte to binary
  * Append these bits to the previously remaining bits
  * Convert these last 11 bits to binary
  * Locate its index in the BIP-39 word list for your language

## Generate cryptographically secure bits
### Generating bits securely
For this, we'll want some way of generating random data. The simplest method are simple coin flips. However, we only
generate one bit at a time with coins, and we can get more with dice. An 8-sided die (d8) can give us 3 uniform bits per
toss. We'll use a d8 for this doc.

Unfortunately, we don't know the bias in the coin or die. Unless we know that we have machine-precision, casino-quality,
balanced dice, we may want to be safe and apply a randomness extractor to our generated results. Unfortunately, this is
wasteful, but it does ensure uniform, unbiased, secure randomness. It's as close to "true random" as we can get.

To do this, we'll apply the [von Neumann randomness extraction method][2]. First, let's define the bits for our d8.
Treat "8" as "0", then just convert to binary. Or we could use the following table:

| Face    | Bits  | Face  | Bits  |
| :-----: | :---: | :---: | :---: |
| **0/8** |  000  | **4** |  100  |
|  **1**  |  001  | **5** |  101  |
|  **2**  |  010  | **6** |  110  |
|  **3**  |  011  | **7** |  111  |

[2]: https://en.wikipedia.org/wiki/Randomness_extractor#Von_Neumann_extractor

Applying the von Neumann randomness extraction method however means that for every 2 consecutive non-overlapping bits,
at best we'll return only 1 bit. We can define this by saying if the two bits are equal, discard them, otherwise return
the leading bit (or the trailing bit; it doesn't matter so long as we remain consistent).

In other words:

| Bits  | Result  |
| :---: | :-----: |
|  00   | discard |
|  01   | 0       |
|  10   | 1       |
|  11   | discard |

For example, suppose I tossed my d8 twice and got "2" and "7". Then my work flow would be something like:

* 2 = 010, 5 = 111
* 010 111 = 010111
* (01)(01)(11) = 0 0 \<discarded\>

So I return 00 from my two tosses, or two bits from six. For a 128-bit security level, I have 126 more bits to generate.
For practice, let's run through a bit longer of an example, so we get the hang of it:

```
d8 results =   2,  5,  5,  6,  4,  6,  5,  8,  7,  4,  5,  6,  7,  7,  8,  1,  8,  3,  4,  5,  1,  1,  2,  3,  1,  7,  2,  3,  7,  1,  7,  6,  8,  4,  4,  1,  5,  7,  5,  1,  7,  7,  6,  1,  4,  8,  4,  7,  4,  7,  7,  2,  1,  6
To binary  = 010,101,101,110,100,110,101,000,111,100,101,110,111,111,000,001,000,011,100,101,001,001,010,011,001,111,010,011,111,001,111,110,000,100,100,001,101,111,101,001,111,111,110,001,100,000,100,111,100,111,111,010,001,110

Paired     = (01)(01)(01)(10)(11)(10)(10)(01)(10)(10)(10)(00)(11)(11)(00)(10)(11)(10)(11)(11)(11)(00)(00)(01)(00)(00)(11)(10)(01)(01)(00)(10)(01)(01)(00)(11)(00)(11)(11)(01)(00)(11)(11)(10)(01)(11)(11)(10)(00)(01)(00)(10)(00)(01)(10)(11)(11)(10)(10)(01)(11)(11)(11)(11)(00)(01)(10)(00)(00)(10)(01)(11)(10)(01)(11)(11)(10)(10)(00)(11)(10)
Extracted  =  0   0   0   1       1   1   0   1   1   1                   1       1                       0               1   0   0       1   0   0                       0               1   0           1       0       1       0   1           1   1   0                       0   1           1   0       1   0           1   1           1  

Result     = 000111011111010010001010101110011010111
```

54 of our d8 tosses resulted so far in 39 securely generated bits. 89 more to go for a 128-bit security level. Yeah.
This is going to be a lot of work. But we wanted to do this by hand, and correctly at that, right?

Note that we can only create Bitcoin mnemonic seeds at the following security levels:

| Security | Words |
| :------: | :---: |
| 128 bits |  12   |
| 160 bits |  15   |
| 192 bits |  18   |
| 224 bits |  21   |
| 256 bits |  24   |

The minimum security level is 128 bits and the maximum security level is 256 bits, with intermediate security levels
every 32 bits.

### Divide into 11-bit bytes
Suppose I ended up with the following 128-bit string:

```
00011101111101001000101010111001101011110011111100000110001100111011111011011110000100000101101000101010111111110000000000010010
```

This needs to be chopped up into 11-bit bytes. However, 128 doesn't divide 11 evenly, as we'll see:

```
00011101111 10100100010 10101110011 01011110011
11110000011 00011001110 11111011011 11000010000
01011010001 01010111111 11000000000 0010010
```

We're 4 bits short of a full 11-bits on that last byte. We need 4 more bits to make a full 11-bit byte. This will become
our "check word" and help ensure that we've entered our mnemonic correctly.

### Convert each 11-bit word to decimal
Now that we have our 11-bit bytes, we need to convert each byte to a decimal number between 0 and 2047. You do recall
your base conversion from school, right? Let's convert the first byte:

```
00011101111 = 0*2¹⁰ + 0*2⁹ + 0*2⁸ + 1*2⁷ + 1*2⁶ + 1*2⁵ + 0*2⁴ + 1*2³ + 1*2² + 1*2¹ + 1*2⁰
            = 0     + 0    + 0    + 128  + 64   + 32   + 0    + 8    + 4    + 2    + 1
            = 239
```

Continue with the rest of the bytes, ignoring the last 7-bit byte oddity at the end, and we end up with:

```
00011101111 =  239
10100100010 = 1314
10101110011 = 1395
01011110011 =  755
11110000011 = 1923
00011001110 =  206
11111011011 = 2011
11000010000 = 1552
01011010001 =  721
01010111111 =  703
11000000000 = 1536
```

### Locate its index in the BIP-39 word list for your language
Now that we have our decimal values, we can locate each value in the BIP-39 word list to found or words to build our
mnemonic. Currently, as of September 4, 2020, there are [9 word lists across 8 different languages][3]. Note that in the
previous step, our results are zero-indexed, meaning `00000000000 = 0` would be the word "abandon" in the English word
list. So `00011101111 = 239` is the 240-th entry, giving us "bulb" not "build".

As such, keeping zero-indexing in mind, using the English word list our mnemonic becomes:

```
 239: bulb
1314: picture
1395: purpose
 755: fury
1923: vacant
 206: border
2011: window
1552: search
 721: focus
 703: fitness
1536: scale

```

Thus our mnemonic is "build picture purpose fury vacant border window search focus fitness scale". All we have left is
to find the check word, and we'll be finished.

[3]: https://github.com/bitcoin/bips/blob/master/bip-0039/bip-0039-wordlists.md

## Hash the original bitstring with SHA-256
Now we need to find which of the 2048 words is our check word. To do this, we have to go back to our original 128-bit
string and hash it with SHA-256. This is the part where we should probably use a trusted computer with SHA-256
installed. Granted, we could [calculate SHA-256 by hand][4], but this procedure is already error-prone enough, and
adding the complexity of calculating SHA-256 digests by hand only increases the risks of errors.

[4]: http://www.righto.com/2014/09/mining-bitcoin-with-pencil-and-paper.html

Most Unix-like operating systems, such as BSD, macOS, and Linux should have Perl installed, and as such, should ship
with `shasum(1)` by default. For Windows, Android, iOS, or other systems, we may need special software to interpret the
ASCII "0" as the machine bit 0, and the ASCII "1" as the machine bit 1.

To do this, run the following command:

```
$ printf 00011101111101001000101010111001101011110011111100000110001100111011111011011110000100000101101000101010111111110000000000010010 | shasum -a 256 -0
a02c53617a4731de3f3d66e87af707224982a10a3fc9c500418ee434b0a6c53e ^-
```

### Appending check bits
Depending on our security level, we will need to append a certain amount of check bits to the end of our bitstring, so
we can find the right check word in our mnemonic. Using the following table below well show how us many check bits are
required for each security level:

| Security | Check  | Total | Words |
| :------: | :----: | :---: | :---: |
| 128 bits | 4 bits |  132  |   12  |
| 160 bits | 5 bits |  165  |   15  |
| 192 bits | 6 bits |  198  |   18  |
| 224 bits | 7 bits |  231  |   21  |
| 256 bits | 8 bits |  264  |   24  |

Because this doc is demonstrating a 128-bit security level, then we need 4 additional bits, bringing the total to 132
required bits to generate a mnemonic seed with the necessary check word.

### Convert the most significant byte to bits
Now that we have our SHA-256 hash, we are only concerned with the most significant 8-bit byte, which in this case is
`0xa0`. Knowing that each hex digit represents 4 bits, we can easily do this by hand, or use this hand-dandy conversion
table:

|  Hex  | Bits  |  Hex  | Bits  |  Hex  | Bits  |  Hex  | Bits  |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 0000  | **4** | 0100  | **8** | 1000  | **c** | 1100  |
| **1** | 0001  | **5** | 0101  | **9** | 1001  | **d** | 1101  |
| **2** | 0010  | **6** | 0110  | **a** | 1010  | **e** | 1110  |
| **3** | 0011  | **7** | 0111  | **b** | 1011  | **f** | 1111  |

So converting `0xa0` to binary becomes `10100000`. Easy peasy.

#### Append these bits to the previous remaining bits
Recall we split our 128-bit string into bytes of 11 bits each, and ended up with a 7-bit byte left. Further, recall that
for a 128-bit security level, we need 4 check bits. So in this case, we really only need the `0xa` from the hex output
of our SHA-256 digest, or `1010` in bits. As such: `0010010` concatenated with `1010` becomes `00100101010`.

### Convert these last 11 bits to binary
Converting this 11-bit byte to binary follows the same procedure as above:

```
00100101010 = 0*2¹⁰ + 0*2⁹ + 1*2⁸ + 0*2⁷ + 0*2⁶ + 1*2⁵ + 0*2⁴ + 1*2³ + 0*2² + 1*2¹ + 0*2⁰
            = 0     + 0    + 256  + 0    + 0    + 32   + 0    + 8    + 0    + 2    + 0
            = 298
```

### Locate its index in the BIP-39 word list for your language
Index 298 gives us BIP-39 word "census" (299-th word, zero-indexed) in the English word list. As such, our final
mnemonic with check is:

```
bulb picture purpose fury vacant border window search focus fitness scale census
```

If we copy and paste our mnemonic against [Ian Coleman's BIP-39 mnemonic code converter][5], we can see that it checks
out. Replace "census" with "celery", and watch the web application produce an error that the check fails with "Invalid
mnemonic".

[5]: https://iancoleman.io/bip39/