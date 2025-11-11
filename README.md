
<!-- README.md is generated from README.Rmd. Please edit that file -->

# toxdrc

<!-- badges: start -->

<!-- badges: end -->

The goal of toxdrc is to provide a simple, easy solution to model and
estimate the dose response relationships in complex data sets. This
package provides a suite of modular functions that can take raw data,
perform quality checks, apply user-specified
transformation/normalization steps, fit and select the best fitting
dose-response model, and estimate specified effect measures across
multiple experimental subsets.

## Installation

You can install the development version of toxdrc from
[GitHub](https://github.com/jsalole/toxdrc) with:

``` r
# install.packages("pak")
pak::pak("jsalole/toxdrc")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(toxdrc)
print(cellglow)
#>              TestID Test_Number    Conc    RFU  Dye   Type Replicate
#> 1    83167_Spiked_A       83167       0  28777   aB Spiked         A
#> 2    83167_Spiked_A       83167       0  27567   aB Spiked         A
#> 3    83167_Spiked_B       83167       0  28985   aB Spiked         B
#> 4    83167_Spiked_B       83167       0  28026   aB Spiked         B
#> 5    83167_Spiked_C       83167       0  26853   aB Spiked         C
#> 6    83167_Spiked_C       83167       0  27831   aB Spiked         C
#> 7    83167_Spiked_A       83167       0  48357 CFDA Spiked         A
#> 8    83167_Spiked_A       83167       0  45468 CFDA Spiked         A
#> 9    83167_Spiked_B       83167       0  48474 CFDA Spiked         B
#> 10   83167_Spiked_B       83167       0  54068 CFDA Spiked         B
#> 11   83167_Spiked_C       83167       0  41494 CFDA Spiked         C
#> 12   83167_Spiked_C       83167       0  47922 CFDA Spiked         C
#> 13   83167_Spiked_A       83167       0  11095   NR Spiked         A
#> 14   83167_Spiked_A       83167       0  11469   NR Spiked         A
#> 15   83167_Spiked_B       83167       0  10761   NR Spiked         B
#> 16   83167_Spiked_B       83167       0  10796   NR Spiked         B
#> 17   83167_Spiked_C       83167       0  10317   NR Spiked         C
#> 18   83167_Spiked_C       83167       0  10896   NR Spiked         C
#> 19   83167_Spiked_A       83167   13.17  25176   aB Spiked         A
#> 20   83167_Spiked_A       83167   13.17  25859   aB Spiked         A
#> 21   83167_Spiked_A       83167   13.17  26554   aB Spiked         A
#> 22   83167_Spiked_B       83167   13.17  25015   aB Spiked         B
#> 23   83167_Spiked_B       83167   13.17  26045   aB Spiked         B
#> 24   83167_Spiked_B       83167   13.17  27408   aB Spiked         B
#> 25   83167_Spiked_C       83167   13.17  24107   aB Spiked         C
#> 26   83167_Spiked_C       83167   13.17  29157   aB Spiked         C
#> 27   83167_Spiked_C       83167   13.17  25239   aB Spiked         C
#> 28   83167_Spiked_A       83167   13.17  46249 CFDA Spiked         A
#> 29   83167_Spiked_A       83167   13.17  47832 CFDA Spiked         A
#> 30   83167_Spiked_A       83167   13.17  49120 CFDA Spiked         A
#> 31   83167_Spiked_B       83167   13.17  48838 CFDA Spiked         B
#> 32   83167_Spiked_B       83167   13.17  47352 CFDA Spiked         B
#> 33   83167_Spiked_B       83167   13.17  47127 CFDA Spiked         B
#> 34   83167_Spiked_C       83167   13.17  47086 CFDA Spiked         C
#> 35   83167_Spiked_C       83167   13.17  45883 CFDA Spiked         C
#> 36   83167_Spiked_C       83167   13.17  42845 CFDA Spiked         C
#> 37   83167_Spiked_A       83167   13.17  10300   NR Spiked         A
#> 38   83167_Spiked_A       83167   13.17   9960   NR Spiked         A
#> 39   83167_Spiked_A       83167   13.17  10208   NR Spiked         A
#> 40   83167_Spiked_B       83167   13.17   8834   NR Spiked         B
#> 41   83167_Spiked_B       83167   13.17   9456   NR Spiked         B
#> 42   83167_Spiked_B       83167   13.17  10559   NR Spiked         B
#> 43   83167_Spiked_C       83167   13.17   9047   NR Spiked         C
#> 44   83167_Spiked_C       83167   13.17  10628   NR Spiked         C
#> 45   83167_Spiked_C       83167   13.17   9551   NR Spiked         C
#> 46   83167_Spiked_A       83167   19.75  24620   aB Spiked         A
#> 47   83167_Spiked_A       83167   19.75  24339   aB Spiked         A
#> 48   83167_Spiked_A       83167   19.75  25401   aB Spiked         A
#> 49   83167_Spiked_B       83167   19.75  25434   aB Spiked         B
#> 50   83167_Spiked_B       83167   19.75  25338   aB Spiked         B
#> 51   83167_Spiked_B       83167   19.75  26347   aB Spiked         B
#> 52   83167_Spiked_C       83167   19.75  24145   aB Spiked         C
#> 53   83167_Spiked_C       83167   19.75  29141   aB Spiked         C
#> 54   83167_Spiked_C       83167   19.75  20225   aB Spiked         C
#> 55   83167_Spiked_A       83167   19.75  49056 CFDA Spiked         A
#> 56   83167_Spiked_A       83167   19.75  51070 CFDA Spiked         A
#> 57   83167_Spiked_A       83167   19.75  49965 CFDA Spiked         A
#> 58   83167_Spiked_B       83167   19.75  46520 CFDA Spiked         B
#> 59   83167_Spiked_B       83167   19.75  49427 CFDA Spiked         B
#> 60   83167_Spiked_B       83167   19.75  45386 CFDA Spiked         B
#> 61   83167_Spiked_C       83167   19.75  42242 CFDA Spiked         C
#> 62   83167_Spiked_C       83167   19.75  50519 CFDA Spiked         C
#> 63   83167_Spiked_C       83167   19.75  51676 CFDA Spiked         C
#> 64   83167_Spiked_A       83167   19.75   9245   NR Spiked         A
#> 65   83167_Spiked_A       83167   19.75   9730   NR Spiked         A
#> 66   83167_Spiked_A       83167   19.75  10184   NR Spiked         A
#> 67   83167_Spiked_B       83167   19.75   8244   NR Spiked         B
#> 68   83167_Spiked_B       83167   19.75  10134   NR Spiked         B
#> 69   83167_Spiked_B       83167   19.75   9683   NR Spiked         B
#> 70   83167_Spiked_C       83167   19.75   8960   NR Spiked         C
#> 71   83167_Spiked_C       83167   19.75  11345   NR Spiked         C
#> 72   83167_Spiked_C       83167   19.75   9876   NR Spiked         C
#> 73   83167_Spiked_A       83167   29.63  20219   aB Spiked         A
#> 74   83167_Spiked_A       83167   29.63  19201   aB Spiked         A
#> 75   83167_Spiked_A       83167   29.63  22197   aB Spiked         A
#> 76   83167_Spiked_B       83167   29.63  20984   aB Spiked         B
#> 77   83167_Spiked_B       83167   29.63  22129   aB Spiked         B
#> 78   83167_Spiked_B       83167   29.63  23435   aB Spiked         B
#> 79   83167_Spiked_C       83167   29.63  17946   aB Spiked         C
#> 80   83167_Spiked_C       83167   29.63  20944   aB Spiked         C
#> 81   83167_Spiked_C       83167   29.63  24432   aB Spiked         C
#> 82   83167_Spiked_A       83167   29.63  48427 CFDA Spiked         A
#> 83   83167_Spiked_A       83167   29.63  51496 CFDA Spiked         A
#> 84   83167_Spiked_A       83167   29.63  51025 CFDA Spiked         A
#> 85   83167_Spiked_B       83167   29.63  46175 CFDA Spiked         B
#> 86   83167_Spiked_B       83167   29.63  48199 CFDA Spiked         B
#> 87   83167_Spiked_B       83167   29.63  50248 CFDA Spiked         B
#> 88   83167_Spiked_C       83167   29.63  54144 CFDA Spiked         C
#> 89   83167_Spiked_C       83167   29.63  51115 CFDA Spiked         C
#> 90   83167_Spiked_C       83167   29.63  48869 CFDA Spiked         C
#> 91   83167_Spiked_A       83167   29.63  10420   NR Spiked         A
#> 92   83167_Spiked_A       83167   29.63   9970   NR Spiked         A
#> 93   83167_Spiked_A       83167   29.63   9756   NR Spiked         A
#> 94   83167_Spiked_B       83167   29.63  10966   NR Spiked         B
#> 95   83167_Spiked_B       83167   29.63  10310   NR Spiked         B
#> 96   83167_Spiked_B       83167   29.63   9741   NR Spiked         B
#> 97   83167_Spiked_C       83167   29.63  10035   NR Spiked         C
#> 98   83167_Spiked_C       83167   29.63   8814   NR Spiked         C
#> 99   83167_Spiked_C       83167   29.63   9544   NR Spiked         C
#> 100  83167_Spiked_A       83167   44.44  15184   aB Spiked         A
#> 101  83167_Spiked_A       83167   44.44  16037   aB Spiked         A
#> 102  83167_Spiked_A       83167   44.44  14859   aB Spiked         A
#> 103  83167_Spiked_B       83167   44.44  15864   aB Spiked         B
#> 104  83167_Spiked_B       83167   44.44  16934   aB Spiked         B
#> 105  83167_Spiked_B       83167   44.44  13552   aB Spiked         B
#> 106  83167_Spiked_C       83167   44.44  15445   aB Spiked         C
#> 107  83167_Spiked_C       83167   44.44  14573   aB Spiked         C
#> 108  83167_Spiked_C       83167   44.44  14619   aB Spiked         C
#> 109  83167_Spiked_A       83167   44.44  47518 CFDA Spiked         A
#> 110  83167_Spiked_A       83167   44.44  49999 CFDA Spiked         A
#> 111  83167_Spiked_A       83167   44.44  46722 CFDA Spiked         A
#> 112  83167_Spiked_B       83167   44.44  48298 CFDA Spiked         B
#> 113  83167_Spiked_B       83167   44.44  50103 CFDA Spiked         B
#> 114  83167_Spiked_B       83167   44.44  53370 CFDA Spiked         B
#> 115  83167_Spiked_C       83167   44.44  48423 CFDA Spiked         C
#> 116  83167_Spiked_C       83167   44.44  52188 CFDA Spiked         C
#> 117  83167_Spiked_C       83167   44.44  45199 CFDA Spiked         C
#> 118  83167_Spiked_A       83167   44.44   6994   NR Spiked         A
#> 119  83167_Spiked_A       83167   44.44   7383   NR Spiked         A
#> 120  83167_Spiked_A       83167   44.44   7268   NR Spiked         A
#> 121  83167_Spiked_B       83167   44.44   7451   NR Spiked         B
#> 122  83167_Spiked_B       83167   44.44   7299   NR Spiked         B
#> 123  83167_Spiked_B       83167   44.44   6301   NR Spiked         B
#> 124  83167_Spiked_C       83167   44.44   7519   NR Spiked         C
#> 125  83167_Spiked_C       83167   44.44   8133   NR Spiked         C
#> 126  83167_Spiked_C       83167   44.44   7132   NR Spiked         C
#> 127  83167_Spiked_A       83167   66.67  14170   aB Spiked         A
#> 128  83167_Spiked_A       83167   66.67  12359   aB Spiked         A
#> 129  83167_Spiked_A       83167   66.67  13975   aB Spiked         A
#> 130  83167_Spiked_B       83167   66.67  11714   aB Spiked         B
#> 131  83167_Spiked_B       83167   66.67  13402   aB Spiked         B
#> 132  83167_Spiked_B       83167   66.67  14023   aB Spiked         B
#> 133  83167_Spiked_C       83167   66.67  12814   aB Spiked         C
#> 134  83167_Spiked_C       83167   66.67  15680   aB Spiked         C
#> 135  83167_Spiked_C       83167   66.67  14325   aB Spiked         C
#> 136  83167_Spiked_A       83167   66.67  26904 CFDA Spiked         A
#> 137  83167_Spiked_A       83167   66.67  28324 CFDA Spiked         A
#> 138  83167_Spiked_A       83167   66.67  25525 CFDA Spiked         A
#> 139  83167_Spiked_B       83167   66.67  23920 CFDA Spiked         B
#> 140  83167_Spiked_B       83167   66.67  26932 CFDA Spiked         B
#> 141  83167_Spiked_B       83167   66.67  26174 CFDA Spiked         B
#> 142  83167_Spiked_C       83167   66.67  26464 CFDA Spiked         C
#> 143  83167_Spiked_C       83167   66.67  25254 CFDA Spiked         C
#> 144  83167_Spiked_C       83167   66.67  21986 CFDA Spiked         C
#> 145  83167_Spiked_A       83167   66.67   4945   NR Spiked         A
#> 146  83167_Spiked_A       83167   66.67   4567   NR Spiked         A
#> 147  83167_Spiked_A       83167   66.67   4927   NR Spiked         A
#> 148  83167_Spiked_B       83167   66.67   5335   NR Spiked         B
#> 149  83167_Spiked_B       83167   66.67   4866   NR Spiked         B
#> 150  83167_Spiked_B       83167   66.67   4984   NR Spiked         B
#> 151  83167_Spiked_C       83167   66.67   5373   NR Spiked         C
#> 152  83167_Spiked_C       83167   66.67   4985   NR Spiked         C
#> 153  83167_Spiked_C       83167   66.67   5132   NR Spiked         C
#> 154  83167_Spiked_A       83167     100   6085   aB Spiked         A
#> 155  83167_Spiked_A       83167     100   6122   aB Spiked         A
#> 156  83167_Spiked_A       83167     100   6027   aB Spiked         A
#> 157  83167_Spiked_B       83167     100   6535   aB Spiked         B
#> 158  83167_Spiked_B       83167     100   5139   aB Spiked         B
#> 159  83167_Spiked_B       83167     100   6291   aB Spiked         B
#> 160  83167_Spiked_C       83167     100   6091   aB Spiked         C
#> 161  83167_Spiked_C       83167     100   6255   aB Spiked         C
#> 162  83167_Spiked_C       83167     100   6167   aB Spiked         C
#> 163  83167_Spiked_A       83167     100   2435 CFDA Spiked         A
#> 164  83167_Spiked_A       83167     100   2246 CFDA Spiked         A
#> 165  83167_Spiked_A       83167     100   4885 CFDA Spiked         A
#> 166  83167_Spiked_B       83167     100   3575 CFDA Spiked         B
#> 167  83167_Spiked_B       83167     100   2822 CFDA Spiked         B
#> 168  83167_Spiked_B       83167     100   3323 CFDA Spiked         B
#> 169  83167_Spiked_C       83167     100   3383 CFDA Spiked         C
#> 170  83167_Spiked_C       83167     100   3281 CFDA Spiked         C
#> 171  83167_Spiked_C       83167     100   3443 CFDA Spiked         C
#> 172  83167_Spiked_A       83167     100   3821   NR Spiked         A
#> 173  83167_Spiked_A       83167     100   2933   NR Spiked         A
#> 174  83167_Spiked_A       83167     100   3671   NR Spiked         A
#> 175  83167_Spiked_B       83167     100   3362   NR Spiked         B
#> 176  83167_Spiked_B       83167     100   3825   NR Spiked         B
#> 177  83167_Spiked_B       83167     100   3431   NR Spiked         B
#> 178  83167_Spiked_C       83167     100   3617   NR Spiked         C
#> 179  83167_Spiked_C       83167     100   3311   NR Spiked         C
#> 180  83167_Spiked_C       83167     100   3738   NR Spiked         C
#> 181  83167_Spiked_A       83167   Blank   5301   aB Spiked         A
#> 182  83167_Spiked_A       83167   Blank   5242   aB Spiked         A
#> 183  83167_Spiked_B       83167   Blank   5887   aB Spiked         B
#> 184  83167_Spiked_B       83167   Blank   5588   aB Spiked         B
#> 185  83167_Spiked_C       83167   Blank   5173   aB Spiked         C
#> 186  83167_Spiked_C       83167   Blank   5609   aB Spiked         C
#> 187  83167_Spiked_A       83167   Blank   1158 CFDA Spiked         A
#> 188  83167_Spiked_A       83167   Blank   1140 CFDA Spiked         A
#> 189  83167_Spiked_B       83167   Blank   1228 CFDA Spiked         B
#> 190  83167_Spiked_B       83167   Blank   1149 CFDA Spiked         B
#> 191  83167_Spiked_C       83167   Blank   1280 CFDA Spiked         C
#> 192  83167_Spiked_C       83167   Blank   1251 CFDA Spiked         C
#> 193  83167_Spiked_A       83167   Blank   1565   NR Spiked         A
#> 194  83167_Spiked_A       83167   Blank   1414   NR Spiked         A
#> 195  83167_Spiked_B       83167   Blank   1598   NR Spiked         B
#> 196  83167_Spiked_B       83167   Blank   1482   NR Spiked         B
#> 197  83167_Spiked_C       83167   Blank   1507   NR Spiked         C
#> 198  83167_Spiked_C       83167   Blank   1481   NR Spiked         C
#> 199  83167_Spiked_A       83167 Control  32861   aB Spiked         A
#> 200  83167_Spiked_A       83167 Control  28086   aB Spiked         A
#> 201  83167_Spiked_B       83167 Control  27458   aB Spiked         B
#> 202  83167_Spiked_B       83167 Control  32506   aB Spiked         B
#> 203  83167_Spiked_C       83167 Control  31452   aB Spiked         C
#> 204  83167_Spiked_C       83167 Control  29030   aB Spiked         C
#> 205  83167_Spiked_A       83167 Control  57197 CFDA Spiked         A
#> 206  83167_Spiked_A       83167 Control  55480 CFDA Spiked         A
#> 207  83167_Spiked_B       83167 Control  45320 CFDA Spiked         B
#> 208  83167_Spiked_B       83167 Control  61085 CFDA Spiked         B
#> 209  83167_Spiked_C       83167 Control  52777 CFDA Spiked         C
#> 210  83167_Spiked_C       83167 Control  50377 CFDA Spiked         C
#> 211  83167_Spiked_A       83167 Control  10371   NR Spiked         A
#> 212  83167_Spiked_A       83167 Control  10706   NR Spiked         A
#> 213  83167_Spiked_B       83167 Control  10070   NR Spiked         B
#> 214  83167_Spiked_B       83167 Control  10485   NR Spiked         B
#> 215  83167_Spiked_C       83167 Control  11672   NR Spiked         C
#> 216  83167_Spiked_C       83167 Control  10058   NR Spiked         C
#> 217  83256_Spiked_A       83256       0  47957   aB Spiked         A
#> 218  83256_Spiked_A       83256       0  51547   aB Spiked         A
#> 219  83256_Spiked_B       83256       0  47670   aB Spiked         B
#> 220  83256_Spiked_B       83256       0  55448   aB Spiked         B
#> 221  83256_Spiked_C       83256       0  47058   aB Spiked         C
#> 222  83256_Spiked_C       83256       0  52454   aB Spiked         C
#> 223  83256_Spiked_A       83256       0 108262 CFDA Spiked         A
#> 224  83256_Spiked_A       83256       0 104549 CFDA Spiked         A
#> 225  83256_Spiked_B       83256       0  92043 CFDA Spiked         B
#> 226  83256_Spiked_B       83256       0 103587 CFDA Spiked         B
#> 227  83256_Spiked_C       83256       0 105500 CFDA Spiked         C
#> 228  83256_Spiked_C       83256       0 111034 CFDA Spiked         C
#> 229  83256_Spiked_A       83256       0   3197   NR Spiked         A
#> 230  83256_Spiked_A       83256       0   3374   NR Spiked         A
#> 231  83256_Spiked_B       83256       0   3701   NR Spiked         B
#> 232  83256_Spiked_B       83256       0   3289   NR Spiked         B
#> 233  83256_Spiked_C       83256       0   3416   NR Spiked         C
#> 234  83256_Spiked_C       83256       0   3736   NR Spiked         C
#> 235  83256_Spiked_A       83256   13.17  48861   aB Spiked         A
#> 236  83256_Spiked_A       83256   13.17  43808   aB Spiked         A
#> 237  83256_Spiked_A       83256   13.17  54141   aB Spiked         A
#> 238  83256_Spiked_B       83256   13.17  49101   aB Spiked         B
#> 239  83256_Spiked_B       83256   13.17  50207   aB Spiked         B
#> 240  83256_Spiked_B       83256   13.17  42550   aB Spiked         B
#> 241  83256_Spiked_C       83256   13.17  46673   aB Spiked         C
#> 242  83256_Spiked_C       83256   13.17  52446   aB Spiked         C
#> 243  83256_Spiked_C       83256   13.17  53612   aB Spiked         C
#> 244  83256_Spiked_A       83256   13.17 106257 CFDA Spiked         A
#> 245  83256_Spiked_A       83256   13.17  97947 CFDA Spiked         A
#> 246  83256_Spiked_A       83256   13.17 109986 CFDA Spiked         A
#> 247  83256_Spiked_B       83256   13.17 104079 CFDA Spiked         B
#> 248  83256_Spiked_B       83256   13.17  96617 CFDA Spiked         B
#> 249  83256_Spiked_B       83256   13.17  96584 CFDA Spiked         B
#> 250  83256_Spiked_C       83256   13.17 118247 CFDA Spiked         C
#> 251  83256_Spiked_C       83256   13.17 105871 CFDA Spiked         C
#> 252  83256_Spiked_C       83256   13.17  90360 CFDA Spiked         C
#> 253  83256_Spiked_A       83256   13.17   3305   NR Spiked         A
#> 254  83256_Spiked_A       83256   13.17   3100   NR Spiked         A
#> 255  83256_Spiked_A       83256   13.17   3363   NR Spiked         A
#> 256  83256_Spiked_B       83256   13.17   3241   NR Spiked         B
#> 257  83256_Spiked_B       83256   13.17   3445   NR Spiked         B
#> 258  83256_Spiked_B       83256   13.17   3051   NR Spiked         B
#> 259  83256_Spiked_C       83256   13.17   3164   NR Spiked         C
#> 260  83256_Spiked_C       83256   13.17   3231   NR Spiked         C
#> 261  83256_Spiked_C       83256   13.17   2960   NR Spiked         C
#> 262  83256_Spiked_A       83256   19.75  50300   aB Spiked         A
#> 263  83256_Spiked_A       83256   19.75  53715   aB Spiked         A
#> 264  83256_Spiked_A       83256   19.75  49222   aB Spiked         A
#> 265  83256_Spiked_B       83256   19.75  53123   aB Spiked         B
#> 266  83256_Spiked_B       83256   19.75  51204   aB Spiked         B
#> 267  83256_Spiked_B       83256   19.75  52897   aB Spiked         B
#> 268  83256_Spiked_C       83256   19.75  50233   aB Spiked         C
#> 269  83256_Spiked_C       83256   19.75  49297   aB Spiked         C
#> 270  83256_Spiked_C       83256   19.75  54039   aB Spiked         C
#> 271  83256_Spiked_A       83256   19.75 112204 CFDA Spiked         A
#> 272  83256_Spiked_A       83256   19.75 117457 CFDA Spiked         A
#> 273  83256_Spiked_A       83256   19.75 113018 CFDA Spiked         A
#> 274  83256_Spiked_B       83256   19.75 117823 CFDA Spiked         B
#> 275  83256_Spiked_B       83256   19.75 123151 CFDA Spiked         B
#> 276  83256_Spiked_B       83256   19.75 112520 CFDA Spiked         B
#> 277  83256_Spiked_C       83256   19.75 112628 CFDA Spiked         C
#> 278  83256_Spiked_C       83256   19.75 108430 CFDA Spiked         C
#> 279  83256_Spiked_C       83256   19.75 115715 CFDA Spiked         C
#> 280  83256_Spiked_A       83256   19.75   3639   NR Spiked         A
#> 281  83256_Spiked_A       83256   19.75   3648   NR Spiked         A
#> 282  83256_Spiked_A       83256   19.75   3547   NR Spiked         A
#> 283  83256_Spiked_B       83256   19.75   3437   NR Spiked         B
#> 284  83256_Spiked_B       83256   19.75   3321   NR Spiked         B
#> 285  83256_Spiked_B       83256   19.75   3427   NR Spiked         B
#> 286  83256_Spiked_C       83256   19.75   3446   NR Spiked         C
#> 287  83256_Spiked_C       83256   19.75   3765   NR Spiked         C
#> 288  83256_Spiked_C       83256   19.75   3638   NR Spiked         C
#> 289  83256_Spiked_A       83256   29.63  36766   aB Spiked         A
#> 290  83256_Spiked_A       83256   29.63  33242   aB Spiked         A
#> 291  83256_Spiked_A       83256   29.63  38214   aB Spiked         A
#> 292  83256_Spiked_B       83256   29.63  29852   aB Spiked         B
#> 293  83256_Spiked_B       83256   29.63  33946   aB Spiked         B
#> 294  83256_Spiked_B       83256   29.63  36123   aB Spiked         B
#> 295  83256_Spiked_C       83256   29.63  40625   aB Spiked         C
#> 296  83256_Spiked_C       83256   29.63  37277   aB Spiked         C
#> 297  83256_Spiked_C       83256   29.63  32041   aB Spiked         C
#> 298  83256_Spiked_A       83256   29.63 113505 CFDA Spiked         A
#> 299  83256_Spiked_A       83256   29.63 116388 CFDA Spiked         A
#> 300  83256_Spiked_A       83256   29.63 105347 CFDA Spiked         A
#> 301  83256_Spiked_B       83256   29.63 108481 CFDA Spiked         B
#> 302  83256_Spiked_B       83256   29.63 133405 CFDA Spiked         B
#> 303  83256_Spiked_B       83256   29.63 115989 CFDA Spiked         B
#> 304  83256_Spiked_C       83256   29.63 123998 CFDA Spiked         C
#> 305  83256_Spiked_C       83256   29.63 115823 CFDA Spiked         C
#> 306  83256_Spiked_C       83256   29.63  91283 CFDA Spiked         C
#> 307  83256_Spiked_A       83256   29.63   3780   NR Spiked         A
#> 308  83256_Spiked_A       83256   29.63   3541   NR Spiked         A
#> 309  83256_Spiked_A       83256   29.63   3549   NR Spiked         A
#> 310  83256_Spiked_B       83256   29.63   4029   NR Spiked         B
#> 311  83256_Spiked_B       83256   29.63   3610   NR Spiked         B
#> 312  83256_Spiked_B       83256   29.63   3278   NR Spiked         B
#> 313  83256_Spiked_C       83256   29.63   3567   NR Spiked         C
#> 314  83256_Spiked_C       83256   29.63   3259   NR Spiked         C
#> 315  83256_Spiked_C       83256   29.63   3404   NR Spiked         C
#> 316  83256_Spiked_A       83256   44.44  25179   aB Spiked         A
#> 317  83256_Spiked_A       83256   44.44  24634   aB Spiked         A
#> 318  83256_Spiked_A       83256   44.44  22943   aB Spiked         A
#> 319  83256_Spiked_B       83256   44.44  27026   aB Spiked         B
#> 320  83256_Spiked_B       83256   44.44  24255   aB Spiked         B
#> 321  83256_Spiked_B       83256   44.44  22784   aB Spiked         B
#> 322  83256_Spiked_C       83256   44.44  23948   aB Spiked         C
#> 323  83256_Spiked_C       83256   44.44  21202   aB Spiked         C
#> 324  83256_Spiked_C       83256   44.44  22143   aB Spiked         C
#> 325  83256_Spiked_A       83256   44.44  75968 CFDA Spiked         A
#> 326  83256_Spiked_A       83256   44.44  71834 CFDA Spiked         A
#> 327  83256_Spiked_A       83256   44.44  77629 CFDA Spiked         A
#> 328  83256_Spiked_B       83256   44.44  82271 CFDA Spiked         B
#> 329  83256_Spiked_B       83256   44.44  78555 CFDA Spiked         B
#> 330  83256_Spiked_B       83256   44.44  70279 CFDA Spiked         B
#> 331  83256_Spiked_C       83256   44.44  67795 CFDA Spiked         C
#> 332  83256_Spiked_C       83256   44.44  76484 CFDA Spiked         C
#> 333  83256_Spiked_C       83256   44.44  78516 CFDA Spiked         C
#> 334  83256_Spiked_A       83256   44.44   3638   NR Spiked         A
#> 335  83256_Spiked_A       83256   44.44   3571   NR Spiked         A
#> 336  83256_Spiked_A       83256   44.44   3575   NR Spiked         A
#> 337  83256_Spiked_B       83256   44.44   3467   NR Spiked         B
#> 338  83256_Spiked_B       83256   44.44   3960   NR Spiked         B
#> 339  83256_Spiked_B       83256   44.44   3209   NR Spiked         B
#> 340  83256_Spiked_C       83256   44.44   3621   NR Spiked         C
#> 341  83256_Spiked_C       83256   44.44   3495   NR Spiked         C
#> 342  83256_Spiked_C       83256   44.44   3391   NR Spiked         C
#> 343  83256_Spiked_A       83256   66.67  13953   aB Spiked         A
#> 344  83256_Spiked_A       83256   66.67  15584   aB Spiked         A
#> 345  83256_Spiked_A       83256   66.67  14652   aB Spiked         A
#> 346  83256_Spiked_B       83256   66.67  12878   aB Spiked         B
#> 347  83256_Spiked_B       83256   66.67  14614   aB Spiked         B
#> 348  83256_Spiked_B       83256   66.67  13961   aB Spiked         B
#> 349  83256_Spiked_C       83256   66.67  16910   aB Spiked         C
#> 350  83256_Spiked_C       83256   66.67  13177   aB Spiked         C
#> 351  83256_Spiked_C       83256   66.67  16537   aB Spiked         C
#> 352  83256_Spiked_A       83256   66.67  38511 CFDA Spiked         A
#> 353  83256_Spiked_A       83256   66.67  40426 CFDA Spiked         A
#> 354  83256_Spiked_A       83256   66.67  37951 CFDA Spiked         A
#> 355  83256_Spiked_B       83256   66.67  41871 CFDA Spiked         B
#> 356  83256_Spiked_B       83256   66.67  40380 CFDA Spiked         B
#> 357  83256_Spiked_B       83256   66.67  39790 CFDA Spiked         B
#> 358  83256_Spiked_C       83256   66.67  38341 CFDA Spiked         C
#> 359  83256_Spiked_C       83256   66.67  41857 CFDA Spiked         C
#> 360  83256_Spiked_C       83256   66.67  36116 CFDA Spiked         C
#> 361  83256_Spiked_A       83256   66.67   3389   NR Spiked         A
#> 362  83256_Spiked_A       83256   66.67   3314   NR Spiked         A
#> 363  83256_Spiked_A       83256   66.67   3402   NR Spiked         A
#> 364  83256_Spiked_B       83256   66.67   3330   NR Spiked         B
#> 365  83256_Spiked_B       83256   66.67   3611   NR Spiked         B
#> 366  83256_Spiked_B       83256   66.67   3584   NR Spiked         B
#> 367  83256_Spiked_C       83256   66.67   3330   NR Spiked         C
#> 368  83256_Spiked_C       83256   66.67   3112   NR Spiked         C
#> 369  83256_Spiked_C       83256   66.67   3521   NR Spiked         C
#> 370  83256_Spiked_A       83256     100   6236   aB Spiked         A
#> 371  83256_Spiked_A       83256     100   6283   aB Spiked         A
#> 372  83256_Spiked_A       83256     100   6443   aB Spiked         A
#> 373  83256_Spiked_B       83256     100   6825   aB Spiked         B
#> 374  83256_Spiked_B       83256     100   6138   aB Spiked         B
#> 375  83256_Spiked_B       83256     100   6875   aB Spiked         B
#> 376  83256_Spiked_C       83256     100   6449   aB Spiked         C
#> 377  83256_Spiked_C       83256     100   5705   aB Spiked         C
#> 378  83256_Spiked_C       83256     100   6224   aB Spiked         C
#> 379  83256_Spiked_A       83256     100   9508 CFDA Spiked         A
#> 380  83256_Spiked_A       83256     100   9147 CFDA Spiked         A
#> 381  83256_Spiked_A       83256     100  10050 CFDA Spiked         A
#> 382  83256_Spiked_B       83256     100   9134 CFDA Spiked         B
#> 383  83256_Spiked_B       83256     100   9162 CFDA Spiked         B
#> 384  83256_Spiked_B       83256     100   9992 CFDA Spiked         B
#> 385  83256_Spiked_C       83256     100   9212 CFDA Spiked         C
#> 386  83256_Spiked_C       83256     100  11281 CFDA Spiked         C
#> 387  83256_Spiked_C       83256     100   9096 CFDA Spiked         C
#> 388  83256_Spiked_A       83256     100   3275   NR Spiked         A
#> 389  83256_Spiked_A       83256     100   3329   NR Spiked         A
#> 390  83256_Spiked_A       83256     100   3202   NR Spiked         A
#> 391  83256_Spiked_B       83256     100   2969   NR Spiked         B
#> 392  83256_Spiked_B       83256     100   3060   NR Spiked         B
#> 393  83256_Spiked_B       83256     100   3065   NR Spiked         B
#> 394  83256_Spiked_C       83256     100   2939   NR Spiked         C
#> 395  83256_Spiked_C       83256     100   3425   NR Spiked         C
#> 396  83256_Spiked_C       83256     100   2926   NR Spiked         C
#> 397  83256_Spiked_A       83256   Blank   6410   aB Spiked         A
#> 398  83256_Spiked_A       83256   Blank   5981   aB Spiked         A
#> 399  83256_Spiked_B       83256   Blank   5914   aB Spiked         B
#> 400  83256_Spiked_B       83256   Blank   6060   aB Spiked         B
#> 401  83256_Spiked_C       83256   Blank   6129   aB Spiked         C
#> 402  83256_Spiked_C       83256   Blank   6241   aB Spiked         C
#> 403  83256_Spiked_A       83256   Blank   1563 CFDA Spiked         A
#> 404  83256_Spiked_A       83256   Blank   1422 CFDA Spiked         A
#> 405  83256_Spiked_B       83256   Blank   1471 CFDA Spiked         B
#> 406  83256_Spiked_B       83256   Blank   1413 CFDA Spiked         B
#> 407  83256_Spiked_C       83256   Blank   1595 CFDA Spiked         C
#> 408  83256_Spiked_C       83256   Blank   1442 CFDA Spiked         C
#> 409  83256_Spiked_A       83256   Blank    578   NR Spiked         A
#> 410  83256_Spiked_A       83256   Blank    575   NR Spiked         A
#> 411  83256_Spiked_B       83256   Blank    607   NR Spiked         B
#> 412  83256_Spiked_B       83256   Blank    595   NR Spiked         B
#> 413  83256_Spiked_C       83256   Blank    621   NR Spiked         C
#> 414  83256_Spiked_C       83256   Blank    624   NR Spiked         C
#> 415  83256_Spiked_A       83256 Control  75348   aB Spiked         A
#> 416  83256_Spiked_A       83256 Control  74702   aB Spiked         A
#> 417  83256_Spiked_B       83256 Control  74446   aB Spiked         B
#> 418  83256_Spiked_B       83256 Control  68970   aB Spiked         B
#> 419  83256_Spiked_C       83256 Control  71096   aB Spiked         C
#> 420  83256_Spiked_C       83256 Control  80109   aB Spiked         C
#> 421  83256_Spiked_A       83256 Control 119526 CFDA Spiked         A
#> 422  83256_Spiked_A       83256 Control 112596 CFDA Spiked         A
#> 423  83256_Spiked_B       83256 Control 113814 CFDA Spiked         B
#> 424  83256_Spiked_B       83256 Control 110494 CFDA Spiked         B
#> 425  83256_Spiked_C       83256 Control 109253 CFDA Spiked         C
#> 426  83256_Spiked_C       83256 Control 110433 CFDA Spiked         C
#> 427  83256_Spiked_A       83256 Control   3451   NR Spiked         A
#> 428  83256_Spiked_A       83256 Control   3459   NR Spiked         A
#> 429  83256_Spiked_B       83256 Control   3898   NR Spiked         B
#> 430  83256_Spiked_B       83256 Control   3569   NR Spiked         B
#> 431  83256_Spiked_C       83256 Control   3762   NR Spiked         C
#> 432  83256_Spiked_C       83256 Control   3636   NR Spiked         C
#> 433  83344_Spiked_A       83344       0 175426   aB Spiked         A
#> 434  83344_Spiked_A       83344       0 169192   aB Spiked         A
#> 435  83344_Spiked_B       83344       0 169697   aB Spiked         B
#> 436  83344_Spiked_B       83344       0 172006   aB Spiked         B
#> 437  83344_Spiked_C       83344       0 196581   aB Spiked         C
#> 438  83344_Spiked_C       83344       0 179721   aB Spiked         C
#> 439  83344_Spiked_A       83344       0 232323 CFDA Spiked         A
#> 440  83344_Spiked_A       83344       0 226046 CFDA Spiked         A
#> 441  83344_Spiked_B       83344       0 237662 CFDA Spiked         B
#> 442  83344_Spiked_B       83344       0 219195 CFDA Spiked         B
#> 443  83344_Spiked_C       83344       0 213217 CFDA Spiked         C
#> 444  83344_Spiked_C       83344       0 199013 CFDA Spiked         C
#> 445  83344_Spiked_A       83344       0   9349   NR Spiked         A
#> 446  83344_Spiked_A       83344       0   8970   NR Spiked         A
#> 447  83344_Spiked_B       83344       0   9085   NR Spiked         B
#> 448  83344_Spiked_B       83344       0   9571   NR Spiked         B
#> 449  83344_Spiked_C       83344       0   9902   NR Spiked         C
#> 450  83344_Spiked_C       83344       0  10733   NR Spiked         C
#> 451  83344_Spiked_A       83344   13.17 154015   aB Spiked         A
#> 452  83344_Spiked_A       83344   13.17 155008   aB Spiked         A
#> 453  83344_Spiked_A       83344   13.17 158691   aB Spiked         A
#> 454  83344_Spiked_B       83344   13.17 160209   aB Spiked         B
#> 455  83344_Spiked_B       83344   13.17 160561   aB Spiked         B
#> 456  83344_Spiked_B       83344   13.17 189325   aB Spiked         B
#> 457  83344_Spiked_C       83344   13.17 138487   aB Spiked         C
#> 458  83344_Spiked_C       83344   13.17 151937   aB Spiked         C
#> 459  83344_Spiked_C       83344   13.17 161638   aB Spiked         C
#> 460  83344_Spiked_A       83344   13.17 237275 CFDA Spiked         A
#> 461  83344_Spiked_A       83344   13.17 238958 CFDA Spiked         A
#> 462  83344_Spiked_A       83344   13.17 245296 CFDA Spiked         A
#> 463  83344_Spiked_B       83344   13.17 266235 CFDA Spiked         B
#> 464  83344_Spiked_B       83344   13.17 202063 CFDA Spiked         B
#> 465  83344_Spiked_B       83344   13.17 238175 CFDA Spiked         B
#> 466  83344_Spiked_C       83344   13.17 249377 CFDA Spiked         C
#> 467  83344_Spiked_C       83344   13.17 224015 CFDA Spiked         C
#> 468  83344_Spiked_C       83344   13.17 279278 CFDA Spiked         C
#> 469  83344_Spiked_A       83344   13.17   9388   NR Spiked         A
#> 470  83344_Spiked_A       83344   13.17   8957   NR Spiked         A
#> 471  83344_Spiked_A       83344   13.17   9613   NR Spiked         A
#> 472  83344_Spiked_B       83344   13.17   9640   NR Spiked         B
#> 473  83344_Spiked_B       83344   13.17   8397   NR Spiked         B
#> 474  83344_Spiked_B       83344   13.17  10016   NR Spiked         B
#> 475  83344_Spiked_C       83344   13.17   8643   NR Spiked         C
#> 476  83344_Spiked_C       83344   13.17   9011   NR Spiked         C
#> 477  83344_Spiked_C       83344   13.17   9710   NR Spiked         C
#> 478  83344_Spiked_A       83344   19.75 141947   aB Spiked         A
#> 479  83344_Spiked_A       83344   19.75 139689   aB Spiked         A
#> 480  83344_Spiked_A       83344   19.75 151596   aB Spiked         A
#> 481  83344_Spiked_B       83344   19.75 144965   aB Spiked         B
#> 482  83344_Spiked_B       83344   19.75 153037   aB Spiked         B
#> 483  83344_Spiked_B       83344   19.75 148462   aB Spiked         B
#> 484  83344_Spiked_C       83344   19.75 118274   aB Spiked         C
#> 485  83344_Spiked_C       83344   19.75 133183   aB Spiked         C
#> 486  83344_Spiked_C       83344   19.75 151620   aB Spiked         C
#> 487  83344_Spiked_A       83344   19.75 236718 CFDA Spiked         A
#> 488  83344_Spiked_A       83344   19.75 237056 CFDA Spiked         A
#> 489  83344_Spiked_A       83344   19.75 238807 CFDA Spiked         A
#> 490  83344_Spiked_B       83344   19.75 215079 CFDA Spiked         B
#> 491  83344_Spiked_B       83344   19.75 240809 CFDA Spiked         B
#> 492  83344_Spiked_B       83344   19.75 260524 CFDA Spiked         B
#> 493  83344_Spiked_C       83344   19.75 226289 CFDA Spiked         C
#> 494  83344_Spiked_C       83344   19.75 266138 CFDA Spiked         C
#> 495  83344_Spiked_C       83344   19.75 255228 CFDA Spiked         C
#> 496  83344_Spiked_A       83344   19.75   8904   NR Spiked         A
#> 497  83344_Spiked_A       83344   19.75   8617   NR Spiked         A
#> 498  83344_Spiked_A       83344   19.75   8971   NR Spiked         A
#> 499  83344_Spiked_B       83344   19.75   9107   NR Spiked         B
#> 500  83344_Spiked_B       83344   19.75   8359   NR Spiked         B
#> 501  83344_Spiked_B       83344   19.75   8496   NR Spiked         B
#> 502  83344_Spiked_C       83344   19.75   8872   NR Spiked         C
#> 503  83344_Spiked_C       83344   19.75   9342   NR Spiked         C
#> 504  83344_Spiked_C       83344   19.75   7699   NR Spiked         C
#> 505  83344_Spiked_A       83344   29.63 128979   aB Spiked         A
#> 506  83344_Spiked_A       83344   29.63 125453   aB Spiked         A
#> 507  83344_Spiked_A       83344   29.63 121955   aB Spiked         A
#> 508  83344_Spiked_B       83344   29.63 119415   aB Spiked         B
#> 509  83344_Spiked_B       83344   29.63 120408   aB Spiked         B
#> 510  83344_Spiked_B       83344   29.63 127252   aB Spiked         B
#> 511  83344_Spiked_C       83344   29.63 120194   aB Spiked         C
#> 512  83344_Spiked_C       83344   29.63 130121   aB Spiked         C
#> 513  83344_Spiked_C       83344   29.63 112071   aB Spiked         C
#> 514  83344_Spiked_A       83344   29.63 223220 CFDA Spiked         A
#> 515  83344_Spiked_A       83344   29.63 215055 CFDA Spiked         A
#> 516  83344_Spiked_A       83344   29.63 216369 CFDA Spiked         A
#> 517  83344_Spiked_B       83344   29.63 188772 CFDA Spiked         B
#> 518  83344_Spiked_B       83344   29.63 186338 CFDA Spiked         B
#> 519  83344_Spiked_B       83344   29.63 189211 CFDA Spiked         B
#> 520  83344_Spiked_C       83344   29.63 226535 CFDA Spiked         C
#> 521  83344_Spiked_C       83344   29.63 231835 CFDA Spiked         C
#> 522  83344_Spiked_C       83344   29.63 211643 CFDA Spiked         C
#> 523  83344_Spiked_A       83344   29.63   8345   NR Spiked         A
#> 524  83344_Spiked_A       83344   29.63   8072   NR Spiked         A
#> 525  83344_Spiked_A       83344   29.63   8570   NR Spiked         A
#> 526  83344_Spiked_B       83344   29.63   8787   NR Spiked         B
#> 527  83344_Spiked_B       83344   29.63   8620   NR Spiked         B
#> 528  83344_Spiked_B       83344   29.63   8194   NR Spiked         B
#> 529  83344_Spiked_C       83344   29.63   8051   NR Spiked         C
#> 530  83344_Spiked_C       83344   29.63   8287   NR Spiked         C
#> 531  83344_Spiked_C       83344   29.63   8098   NR Spiked         C
#> 532  83344_Spiked_A       83344   44.44  61313   aB Spiked         A
#> 533  83344_Spiked_A       83344   44.44  65233   aB Spiked         A
#> 534  83344_Spiked_A       83344   44.44  72066   aB Spiked         A
#> 535  83344_Spiked_B       83344   44.44  73016   aB Spiked         B
#> 536  83344_Spiked_B       83344   44.44  61089   aB Spiked         B
#> 537  83344_Spiked_B       83344   44.44  70510   aB Spiked         B
#> 538  83344_Spiked_C       83344   44.44  63837   aB Spiked         C
#> 539  83344_Spiked_C       83344   44.44  61991   aB Spiked         C
#> 540  83344_Spiked_C       83344   44.44  61167   aB Spiked         C
#> 541  83344_Spiked_A       83344   44.44 153309 CFDA Spiked         A
#> 542  83344_Spiked_A       83344   44.44 125054 CFDA Spiked         A
#> 543  83344_Spiked_A       83344   44.44 173346 CFDA Spiked         A
#> 544  83344_Spiked_B       83344   44.44 153008 CFDA Spiked         B
#> 545  83344_Spiked_B       83344   44.44 151688 CFDA Spiked         B
#> 546  83344_Spiked_B       83344   44.44 141110 CFDA Spiked         B
#> 547  83344_Spiked_C       83344   44.44 138779 CFDA Spiked         C
#> 548  83344_Spiked_C       83344   44.44 163614 CFDA Spiked         C
#> 549  83344_Spiked_C       83344   44.44 154391 CFDA Spiked         C
#> 550  83344_Spiked_A       83344   44.44   6647   NR Spiked         A
#> 551  83344_Spiked_A       83344   44.44   7407   NR Spiked         A
#> 552  83344_Spiked_A       83344   44.44   7143   NR Spiked         A
#> 553  83344_Spiked_B       83344   44.44   6940   NR Spiked         B
#> 554  83344_Spiked_B       83344   44.44   6446   NR Spiked         B
#> 555  83344_Spiked_B       83344   44.44   7435   NR Spiked         B
#> 556  83344_Spiked_C       83344   44.44   6973   NR Spiked         C
#> 557  83344_Spiked_C       83344   44.44   6821   NR Spiked         C
#> 558  83344_Spiked_C       83344   44.44   7054   NR Spiked         C
#> 559  83344_Spiked_A       83344   66.67  10409   aB Spiked         A
#> 560  83344_Spiked_A       83344   66.67  13051   aB Spiked         A
#> 561  83344_Spiked_A       83344   66.67  15612   aB Spiked         A
#> 562  83344_Spiked_B       83344   66.67  14225   aB Spiked         B
#> 563  83344_Spiked_B       83344   66.67  13263   aB Spiked         B
#> 564  83344_Spiked_B       83344   66.67  13761   aB Spiked         B
#> 565  83344_Spiked_C       83344   66.67  13778   aB Spiked         C
#> 566  83344_Spiked_C       83344   66.67  12962   aB Spiked         C
#> 567  83344_Spiked_C       83344   66.67  12205   aB Spiked         C
#> 568  83344_Spiked_A       83344   66.67  60152 CFDA Spiked         A
#> 569  83344_Spiked_A       83344   66.67  65097 CFDA Spiked         A
#> 570  83344_Spiked_A       83344   66.67  56696 CFDA Spiked         A
#> 571  83344_Spiked_B       83344   66.67  63790 CFDA Spiked         B
#> 572  83344_Spiked_B       83344   66.67  62856 CFDA Spiked         B
#> 573  83344_Spiked_B       83344   66.67  62269 CFDA Spiked         B
#> 574  83344_Spiked_C       83344   66.67  66631 CFDA Spiked         C
#> 575  83344_Spiked_C       83344   66.67  57928 CFDA Spiked         C
#> 576  83344_Spiked_C       83344   66.67  66291 CFDA Spiked         C
#> 577  83344_Spiked_A       83344   66.67   5332   NR Spiked         A
#> 578  83344_Spiked_A       83344   66.67   5472   NR Spiked         A
#> 579  83344_Spiked_A       83344   66.67   5326   NR Spiked         A
#> 580  83344_Spiked_B       83344   66.67   5352   NR Spiked         B
#> 581  83344_Spiked_B       83344   66.67   4935   NR Spiked         B
#> 582  83344_Spiked_B       83344   66.67   4397   NR Spiked         B
#> 583  83344_Spiked_C       83344   66.67   5383   NR Spiked         C
#> 584  83344_Spiked_C       83344   66.67   5296   NR Spiked         C
#> 585  83344_Spiked_C       83344   66.67   5027   NR Spiked         C
#> 586  83344_Spiked_A       83344     100   6277   aB Spiked         A
#> 587  83344_Spiked_A       83344     100   6267   aB Spiked         A
#> 588  83344_Spiked_A       83344     100   6375   aB Spiked         A
#> 589  83344_Spiked_B       83344     100   5892   aB Spiked         B
#> 590  83344_Spiked_B       83344     100   6835   aB Spiked         B
#> 591  83344_Spiked_B       83344     100   5467   aB Spiked         B
#> 592  83344_Spiked_C       83344     100   6252   aB Spiked         C
#> 593  83344_Spiked_C       83344     100   6664   aB Spiked         C
#> 594  83344_Spiked_C       83344     100   6233   aB Spiked         C
#> 595  83344_Spiked_A       83344     100   5679 CFDA Spiked         A
#> 596  83344_Spiked_A       83344     100   7310 CFDA Spiked         A
#> 597  83344_Spiked_A       83344     100   6399 CFDA Spiked         A
#> 598  83344_Spiked_B       83344     100   6796 CFDA Spiked         B
#> 599  83344_Spiked_B       83344     100   5931 CFDA Spiked         B
#> 600  83344_Spiked_B       83344     100   6766 CFDA Spiked         B
#> 601  83344_Spiked_C       83344     100   7031 CFDA Spiked         C
#> 602  83344_Spiked_C       83344     100   6309 CFDA Spiked         C
#> 603  83344_Spiked_C       83344     100   6215 CFDA Spiked         C
#> 604  83344_Spiked_A       83344     100   3022   NR Spiked         A
#> 605  83344_Spiked_A       83344     100   2718   NR Spiked         A
#> 606  83344_Spiked_A       83344     100   2500   NR Spiked         A
#> 607  83344_Spiked_B       83344     100   2903   NR Spiked         B
#> 608  83344_Spiked_B       83344     100   2524   NR Spiked         B
#> 609  83344_Spiked_B       83344     100   2446   NR Spiked         B
#> 610  83344_Spiked_C       83344     100   2629   NR Spiked         C
#> 611  83344_Spiked_C       83344     100   2926   NR Spiked         C
#> 612  83344_Spiked_C       83344     100   2699   NR Spiked         C
#> 613  83344_Spiked_A       83344   Blank   6161   aB Spiked         A
#> 614  83344_Spiked_A       83344   Blank   6225   aB Spiked         A
#> 615  83344_Spiked_B       83344   Blank   5567   aB Spiked         B
#> 616  83344_Spiked_B       83344   Blank   6879   aB Spiked         B
#> 617  83344_Spiked_C       83344   Blank   5983   aB Spiked         C
#> 618  83344_Spiked_C       83344   Blank   6311   aB Spiked         C
#> 619  83344_Spiked_A       83344   Blank   1469 CFDA Spiked         A
#> 620  83344_Spiked_A       83344   Blank   1791 CFDA Spiked         A
#> 621  83344_Spiked_B       83344   Blank   1721 CFDA Spiked         B
#> 622  83344_Spiked_B       83344   Blank   1732 CFDA Spiked         B
#> 623  83344_Spiked_C       83344   Blank   1596 CFDA Spiked         C
#> 624  83344_Spiked_C       83344   Blank   1519 CFDA Spiked         C
#> 625  83344_Spiked_A       83344   Blank   1612   NR Spiked         A
#> 626  83344_Spiked_A       83344   Blank   1559   NR Spiked         A
#> 627  83344_Spiked_B       83344   Blank   1585   NR Spiked         B
#> 628  83344_Spiked_B       83344   Blank   1566   NR Spiked         B
#> 629  83344_Spiked_C       83344   Blank   1568   NR Spiked         C
#> 630  83344_Spiked_C       83344   Blank   1688   NR Spiked         C
#> 631  83344_Spiked_A       83344 Control 156441   aB Spiked         A
#> 632  83344_Spiked_A       83344 Control 159465   aB Spiked         A
#> 633  83344_Spiked_B       83344 Control 161479   aB Spiked         B
#> 634  83344_Spiked_B       83344 Control 140757   aB Spiked         B
#> 635  83344_Spiked_C       83344 Control 164223   aB Spiked         C
#> 636  83344_Spiked_C       83344 Control 169544   aB Spiked         C
#> 637  83344_Spiked_A       83344 Control 213020 CFDA Spiked         A
#> 638  83344_Spiked_A       83344 Control 221747 CFDA Spiked         A
#> 639  83344_Spiked_B       83344 Control 242803 CFDA Spiked         B
#> 640  83344_Spiked_B       83344 Control 260349 CFDA Spiked         B
#> 641  83344_Spiked_C       83344 Control 218222 CFDA Spiked         C
#> 642  83344_Spiked_C       83344 Control 216134 CFDA Spiked         C
#> 643  83344_Spiked_A       83344 Control   8002   NR Spiked         A
#> 644  83344_Spiked_A       83344 Control   9098   NR Spiked         A
#> 645  83344_Spiked_B       83344 Control   7602   NR Spiked         B
#> 646  83344_Spiked_B       83344 Control   8441   NR Spiked         B
#> 647  83344_Spiked_C       83344 Control   8700   NR Spiked         C
#> 648  83344_Spiked_C       83344 Control   9515   NR Spiked         C
#> 649  83475_Spiked_A       83475       0 115462   aB Spiked         A
#> 650  83475_Spiked_A       83475       0 114620   aB Spiked         A
#> 651  83475_Spiked_B       83475       0 112372   aB Spiked         B
#> 652  83475_Spiked_B       83475       0 112580   aB Spiked         B
#> 653  83475_Spiked_C       83475       0 108211   aB Spiked         C
#> 654  83475_Spiked_C       83475       0 117469   aB Spiked         C
#> 655  83475_Spiked_A       83475       0 115830 CFDA Spiked         A
#> 656  83475_Spiked_A       83475       0 104203 CFDA Spiked         A
#> 657  83475_Spiked_B       83475       0 103526 CFDA Spiked         B
#> 658  83475_Spiked_B       83475       0 121833 CFDA Spiked         B
#> 659  83475_Spiked_C       83475       0 117966 CFDA Spiked         C
#> 660  83475_Spiked_C       83475       0  90651 CFDA Spiked         C
#> 661  83475_Spiked_A       83475       0   4210   NR Spiked         A
#> 662  83475_Spiked_A       83475       0   4340   NR Spiked         A
#> 663  83475_Spiked_B       83475       0   3989   NR Spiked         B
#> 664  83475_Spiked_B       83475       0   4281   NR Spiked         B
#> 665  83475_Spiked_C       83475       0   4105   NR Spiked         C
#> 666  83475_Spiked_C       83475       0   4603   NR Spiked         C
#> 667  83475_Spiked_A       83475   13.17  93187   aB Spiked         A
#> 668  83475_Spiked_A       83475   13.17  93174   aB Spiked         A
#> 669  83475_Spiked_A       83475   13.17  91798   aB Spiked         A
#> 670  83475_Spiked_B       83475   13.17  96534   aB Spiked         B
#> 671  83475_Spiked_B       83475   13.17  95001   aB Spiked         B
#> 672  83475_Spiked_B       83475   13.17  93113   aB Spiked         B
#> 673  83475_Spiked_C       83475   13.17  92626   aB Spiked         C
#> 674  83475_Spiked_C       83475   13.17 105718   aB Spiked         C
#> 675  83475_Spiked_C       83475   13.17 103004   aB Spiked         C
#> 676  83475_Spiked_A       83475   13.17  80047 CFDA Spiked         A
#> 677  83475_Spiked_A       83475   13.17  76607 CFDA Spiked         A
#> 678  83475_Spiked_A       83475   13.17  86376 CFDA Spiked         A
#> 679  83475_Spiked_B       83475   13.17  87873 CFDA Spiked         B
#> 680  83475_Spiked_B       83475   13.17  89849 CFDA Spiked         B
#> 681  83475_Spiked_B       83475   13.17  83702 CFDA Spiked         B
#> 682  83475_Spiked_C       83475   13.17  74195 CFDA Spiked         C
#> 683  83475_Spiked_C       83475   13.17  82848 CFDA Spiked         C
#> 684  83475_Spiked_C       83475   13.17  86753 CFDA Spiked         C
#> 685  83475_Spiked_A       83475   13.17   4417   NR Spiked         A
#> 686  83475_Spiked_A       83475   13.17   4399   NR Spiked         A
#> 687  83475_Spiked_A       83475   13.17   4433   NR Spiked         A
#> 688  83475_Spiked_B       83475   13.17   4889   NR Spiked         B
#> 689  83475_Spiked_B       83475   13.17   4151   NR Spiked         B
#> 690  83475_Spiked_B       83475   13.17   4932   NR Spiked         B
#> 691  83475_Spiked_C       83475   13.17   5045   NR Spiked         C
#> 692  83475_Spiked_C       83475   13.17   4594   NR Spiked         C
#> 693  83475_Spiked_C       83475   13.17   3914   NR Spiked         C
#> 694  83475_Spiked_A       83475   19.75  79415   aB Spiked         A
#> 695  83475_Spiked_A       83475   19.75  79771   aB Spiked         A
#> 696  83475_Spiked_A       83475   19.75  87659   aB Spiked         A
#> 697  83475_Spiked_B       83475   19.75  88905   aB Spiked         B
#> 698  83475_Spiked_B       83475   19.75  87220   aB Spiked         B
#> 699  83475_Spiked_B       83475   19.75  73693   aB Spiked         B
#> 700  83475_Spiked_C       83475   19.75  82674   aB Spiked         C
#> 701  83475_Spiked_C       83475   19.75  85475   aB Spiked         C
#> 702  83475_Spiked_C       83475   19.75  80676   aB Spiked         C
#> 703  83475_Spiked_A       83475   19.75  83127 CFDA Spiked         A
#> 704  83475_Spiked_A       83475   19.75  74860 CFDA Spiked         A
#> 705  83475_Spiked_A       83475   19.75  86295 CFDA Spiked         A
#> 706  83475_Spiked_B       83475   19.75  72777 CFDA Spiked         B
#> 707  83475_Spiked_B       83475   19.75  73966 CFDA Spiked         B
#> 708  83475_Spiked_B       83475   19.75  72655 CFDA Spiked         B
#> 709  83475_Spiked_C       83475   19.75  83320 CFDA Spiked         C
#> 710  83475_Spiked_C       83475   19.75  81049 CFDA Spiked         C
#> 711  83475_Spiked_C       83475   19.75  81797 CFDA Spiked         C
#> 712  83475_Spiked_A       83475   19.75   4329   NR Spiked         A
#> 713  83475_Spiked_A       83475   19.75   4631   NR Spiked         A
#> 714  83475_Spiked_A       83475   19.75   4102   NR Spiked         A
#> 715  83475_Spiked_B       83475   19.75   4061   NR Spiked         B
#> 716  83475_Spiked_B       83475   19.75   3755   NR Spiked         B
#> 717  83475_Spiked_B       83475   19.75   4493   NR Spiked         B
#> 718  83475_Spiked_C       83475   19.75   3878   NR Spiked         C
#> 719  83475_Spiked_C       83475   19.75   5079   NR Spiked         C
#> 720  83475_Spiked_C       83475   19.75   4890   NR Spiked         C
#> 721  83475_Spiked_A       83475   29.63  69446   aB Spiked         A
#> 722  83475_Spiked_A       83475   29.63  73825   aB Spiked         A
#> 723  83475_Spiked_A       83475   29.63  62722   aB Spiked         A
#> 724  83475_Spiked_B       83475   29.63  61397   aB Spiked         B
#> 725  83475_Spiked_B       83475   29.63  63234   aB Spiked         B
#> 726  83475_Spiked_B       83475   29.63  64770   aB Spiked         B
#> 727  83475_Spiked_C       83475   29.63  71942   aB Spiked         C
#> 728  83475_Spiked_C       83475   29.63  65602   aB Spiked         C
#> 729  83475_Spiked_C       83475   29.63  61538   aB Spiked         C
#> 730  83475_Spiked_A       83475   29.63  69444 CFDA Spiked         A
#> 731  83475_Spiked_A       83475   29.63  67354 CFDA Spiked         A
#> 732  83475_Spiked_A       83475   29.63  77823 CFDA Spiked         A
#> 733  83475_Spiked_B       83475   29.63  78760 CFDA Spiked         B
#> 734  83475_Spiked_B       83475   29.63  64141 CFDA Spiked         B
#> 735  83475_Spiked_B       83475   29.63  65260 CFDA Spiked         B
#> 736  83475_Spiked_C       83475   29.63  67601 CFDA Spiked         C
#> 737  83475_Spiked_C       83475   29.63  65181 CFDA Spiked         C
#> 738  83475_Spiked_C       83475   29.63  65650 CFDA Spiked         C
#> 739  83475_Spiked_A       83475   29.63   3906   NR Spiked         A
#> 740  83475_Spiked_A       83475   29.63   3514   NR Spiked         A
#> 741  83475_Spiked_A       83475   29.63   3700   NR Spiked         A
#> 742  83475_Spiked_B       83475   29.63   3950   NR Spiked         B
#> 743  83475_Spiked_B       83475   29.63   4476   NR Spiked         B
#> 744  83475_Spiked_B       83475   29.63   3169   NR Spiked         B
#> 745  83475_Spiked_C       83475   29.63   3501   NR Spiked         C
#> 746  83475_Spiked_C       83475   29.63   3178   NR Spiked         C
#> 747  83475_Spiked_C       83475   29.63   3189   NR Spiked         C
#> 748  83475_Spiked_A       83475   44.44  54654   aB Spiked         A
#> 749  83475_Spiked_A       83475   44.44  54121   aB Spiked         A
#> 750  83475_Spiked_A       83475   44.44  57337   aB Spiked         A
#> 751  83475_Spiked_B       83475   44.44  56640   aB Spiked         B
#> 752  83475_Spiked_B       83475   44.44  55432   aB Spiked         B
#> 753  83475_Spiked_B       83475   44.44  52880   aB Spiked         B
#> 754  83475_Spiked_C       83475   44.44  52564   aB Spiked         C
#> 755  83475_Spiked_C       83475   44.44  51902   aB Spiked         C
#> 756  83475_Spiked_C       83475   44.44  55252   aB Spiked         C
#> 757  83475_Spiked_A       83475   44.44  83382 CFDA Spiked         A
#> 758  83475_Spiked_A       83475   44.44  77280 CFDA Spiked         A
#> 759  83475_Spiked_A       83475   44.44  89000 CFDA Spiked         A
#> 760  83475_Spiked_B       83475   44.44  91605 CFDA Spiked         B
#> 761  83475_Spiked_B       83475   44.44  83879 CFDA Spiked         B
#> 762  83475_Spiked_B       83475   44.44  80763 CFDA Spiked         B
#> 763  83475_Spiked_C       83475   44.44  84230 CFDA Spiked         C
#> 764  83475_Spiked_C       83475   44.44  77748 CFDA Spiked         C
#> 765  83475_Spiked_C       83475   44.44  77380 CFDA Spiked         C
#> 766  83475_Spiked_A       83475   44.44   3083   NR Spiked         A
#> 767  83475_Spiked_A       83475   44.44   3379   NR Spiked         A
#> 768  83475_Spiked_A       83475   44.44   3909   NR Spiked         A
#> 769  83475_Spiked_B       83475   44.44   3552   NR Spiked         B
#> 770  83475_Spiked_B       83475   44.44   3391   NR Spiked         B
#> 771  83475_Spiked_B       83475   44.44   3502   NR Spiked         B
#> 772  83475_Spiked_C       83475   44.44   3515   NR Spiked         C
#> 773  83475_Spiked_C       83475   44.44   3258   NR Spiked         C
#> 774  83475_Spiked_C       83475   44.44   2633   NR Spiked         C
#> 775  83475_Spiked_A       83475   66.67  16881   aB Spiked         A
#> 776  83475_Spiked_A       83475   66.67  21755   aB Spiked         A
#> 777  83475_Spiked_A       83475   66.67  28222   aB Spiked         A
#> 778  83475_Spiked_B       83475   66.67  21274   aB Spiked         B
#> 779  83475_Spiked_B       83475   66.67  23814   aB Spiked         B
#> 780  83475_Spiked_B       83475   66.67  21098   aB Spiked         B
#> 781  83475_Spiked_C       83475   66.67  18860   aB Spiked         C
#> 782  83475_Spiked_C       83475   66.67  22431   aB Spiked         C
#> 783  83475_Spiked_C       83475   66.67  21992   aB Spiked         C
#> 784  83475_Spiked_A       83475   66.67  17071 CFDA Spiked         A
#> 785  83475_Spiked_A       83475   66.67  20738 CFDA Spiked         A
#> 786  83475_Spiked_A       83475   66.67  22515 CFDA Spiked         A
#> 787  83475_Spiked_B       83475   66.67  17325 CFDA Spiked         B
#> 788  83475_Spiked_B       83475   66.67  19362 CFDA Spiked         B
#> 789  83475_Spiked_B       83475   66.67  19084 CFDA Spiked         B
#> 790  83475_Spiked_C       83475   66.67  18637 CFDA Spiked         C
#> 791  83475_Spiked_C       83475   66.67  20476 CFDA Spiked         C
#> 792  83475_Spiked_C       83475   66.67  19400 CFDA Spiked         C
#> 793  83475_Spiked_A       83475   66.67   2510   NR Spiked         A
#> 794  83475_Spiked_A       83475   66.67   2744   NR Spiked         A
#> 795  83475_Spiked_A       83475   66.67   2932   NR Spiked         A
#> 796  83475_Spiked_B       83475   66.67   2677   NR Spiked         B
#> 797  83475_Spiked_B       83475   66.67   2739   NR Spiked         B
#> 798  83475_Spiked_B       83475   66.67   2706   NR Spiked         B
#> 799  83475_Spiked_C       83475   66.67   3241   NR Spiked         C
#> 800  83475_Spiked_C       83475   66.67   2779   NR Spiked         C
#> 801  83475_Spiked_C       83475   66.67   3310   NR Spiked         C
#> 802  83475_Spiked_A       83475     100   6631   aB Spiked         A
#> 803  83475_Spiked_A       83475     100   6747   aB Spiked         A
#> 804  83475_Spiked_A       83475     100   6860   aB Spiked         A
#> 805  83475_Spiked_B       83475     100   6467   aB Spiked         B
#> 806  83475_Spiked_B       83475     100   6943   aB Spiked         B
#> 807  83475_Spiked_B       83475     100   7573   aB Spiked         B
#> 808  83475_Spiked_C       83475     100   7027   aB Spiked         C
#> 809  83475_Spiked_C       83475     100   6713   aB Spiked         C
#> 810  83475_Spiked_C       83475     100   6790   aB Spiked         C
#> 811  83475_Spiked_A       83475     100   2244 CFDA Spiked         A
#> 812  83475_Spiked_A       83475     100   2392 CFDA Spiked         A
#> 813  83475_Spiked_A       83475     100   2618 CFDA Spiked         A
#> 814  83475_Spiked_B       83475     100   2552 CFDA Spiked         B
#> 815  83475_Spiked_B       83475     100   2537 CFDA Spiked         B
#> 816  83475_Spiked_B       83475     100   2580 CFDA Spiked         B
#> 817  83475_Spiked_C       83475     100   2681 CFDA Spiked         C
#> 818  83475_Spiked_C       83475     100   2658 CFDA Spiked         C
#> 819  83475_Spiked_C       83475     100   2347 CFDA Spiked         C
#> 820  83475_Spiked_A       83475     100   2529   NR Spiked         A
#> 821  83475_Spiked_A       83475     100   2136   NR Spiked         A
#> 822  83475_Spiked_A       83475     100   2203   NR Spiked         A
#> 823  83475_Spiked_B       83475     100   2225   NR Spiked         B
#> 824  83475_Spiked_B       83475     100   2411   NR Spiked         B
#> 825  83475_Spiked_B       83475     100   2288   NR Spiked         B
#> 826  83475_Spiked_C       83475     100   2142   NR Spiked         C
#> 827  83475_Spiked_C       83475     100   2201   NR Spiked         C
#> 828  83475_Spiked_C       83475     100   2056   NR Spiked         C
#> 829  83475_Spiked_A       83475   Blank   7125   aB Spiked         A
#> 830  83475_Spiked_A       83475   Blank   8066   aB Spiked         A
#> 831  83475_Spiked_B       83475   Blank   7446   aB Spiked         B
#> 832  83475_Spiked_B       83475   Blank   7658   aB Spiked         B
#> 833  83475_Spiked_C       83475   Blank   7273   aB Spiked         C
#> 834  83475_Spiked_C       83475   Blank   7865   aB Spiked         C
#> 835  83475_Spiked_A       83475   Blank   1756 CFDA Spiked         A
#> 836  83475_Spiked_A       83475   Blank   2343 CFDA Spiked         A
#> 837  83475_Spiked_B       83475   Blank   1754 CFDA Spiked         B
#> 838  83475_Spiked_B       83475   Blank   2129 CFDA Spiked         B
#> 839  83475_Spiked_C       83475   Blank   2011 CFDA Spiked         C
#> 840  83475_Spiked_C       83475   Blank   1967 CFDA Spiked         C
#> 841  83475_Spiked_A       83475   Blank   2394   NR Spiked         A
#> 842  83475_Spiked_A       83475   Blank   1763   NR Spiked         A
#> 843  83475_Spiked_B       83475   Blank   1806   NR Spiked         B
#> 844  83475_Spiked_B       83475   Blank   1982   NR Spiked         B
#> 845  83475_Spiked_C       83475   Blank   2351   NR Spiked         C
#> 846  83475_Spiked_C       83475   Blank   2243   NR Spiked         C
#> 847  83475_Spiked_A       83475 Control 131827   aB Spiked         A
#> 848  83475_Spiked_A       83475 Control 134523   aB Spiked         A
#> 849  83475_Spiked_B       83475 Control 132269   aB Spiked         B
#> 850  83475_Spiked_B       83475 Control 138009   aB Spiked         B
#> 851  83475_Spiked_C       83475 Control 134799   aB Spiked         C
#> 852  83475_Spiked_C       83475 Control 129431   aB Spiked         C
#> 853  83475_Spiked_A       83475 Control 285192 CFDA Spiked         A
#> 854  83475_Spiked_A       83475 Control 297080 CFDA Spiked         A
#> 855  83475_Spiked_B       83475 Control 305803 CFDA Spiked         B
#> 856  83475_Spiked_B       83475 Control 262151 CFDA Spiked         B
#> 857  83475_Spiked_C       83475 Control 280683 CFDA Spiked         C
#> 858  83475_Spiked_C       83475 Control 276986 CFDA Spiked         C
#> 859  83475_Spiked_A       83475 Control   7044   NR Spiked         A
#> 860  83475_Spiked_A       83475 Control   7304   NR Spiked         A
#> 861  83475_Spiked_B       83475 Control   6503   NR Spiked         B
#> 862  83475_Spiked_B       83475 Control   7362   NR Spiked         B
#> 863  83475_Spiked_C       83475 Control   7770   NR Spiked         C
#> 864  83475_Spiked_C       83475 Control   6980   NR Spiked         C
#> 865  83476_Spiked_A       83476       0  74479   aB Spiked         A
#> 866  83476_Spiked_A       83476       0  66962   aB Spiked         A
#> 867  83476_Spiked_B       83476       0  81786   aB Spiked         B
#> 868  83476_Spiked_B       83476       0  74217   aB Spiked         B
#> 869  83476_Spiked_C       83476       0  69421   aB Spiked         C
#> 870  83476_Spiked_C       83476       0  63331   aB Spiked         C
#> 871  83476_Spiked_A       83476       0 137436 CFDA Spiked         A
#> 872  83476_Spiked_A       83476       0 158436 CFDA Spiked         A
#> 873  83476_Spiked_B       83476       0 153542 CFDA Spiked         B
#> 874  83476_Spiked_B       83476       0 129574 CFDA Spiked         B
#> 875  83476_Spiked_C       83476       0 147559 CFDA Spiked         C
#> 876  83476_Spiked_C       83476       0 136886 CFDA Spiked         C
#> 877  83476_Spiked_A       83476       0   8090   NR Spiked         A
#> 878  83476_Spiked_A       83476       0   8168   NR Spiked         A
#> 879  83476_Spiked_B       83476       0   7913   NR Spiked         B
#> 880  83476_Spiked_B       83476       0   8597   NR Spiked         B
#> 881  83476_Spiked_C       83476       0   7579   NR Spiked         C
#> 882  83476_Spiked_C       83476       0   6852   NR Spiked         C
#> 883  83476_Spiked_A       83476   13.17  72309   aB Spiked         A
#> 884  83476_Spiked_A       83476   13.17  69088   aB Spiked         A
#> 885  83476_Spiked_A       83476   13.17  65434   aB Spiked         A
#> 886  83476_Spiked_B       83476   13.17  74041   aB Spiked         B
#> 887  83476_Spiked_B       83476   13.17  72304   aB Spiked         B
#> 888  83476_Spiked_B       83476   13.17  68959   aB Spiked         B
#> 889  83476_Spiked_C       83476   13.17  72777   aB Spiked         C
#> 890  83476_Spiked_C       83476   13.17  67423   aB Spiked         C
#> 891  83476_Spiked_C       83476   13.17  75552   aB Spiked         C
#> 892  83476_Spiked_A       83476   13.17 124003 CFDA Spiked         A
#> 893  83476_Spiked_A       83476   13.17 116546 CFDA Spiked         A
#> 894  83476_Spiked_A       83476   13.17 111595 CFDA Spiked         A
#> 895  83476_Spiked_B       83476   13.17 126274 CFDA Spiked         B
#> 896  83476_Spiked_B       83476   13.17 120126 CFDA Spiked         B
#> 897  83476_Spiked_B       83476   13.17 112017 CFDA Spiked         B
#> 898  83476_Spiked_C       83476   13.17 118889 CFDA Spiked         C
#> 899  83476_Spiked_C       83476   13.17 101578 CFDA Spiked         C
#> 900  83476_Spiked_C       83476   13.17 117763 CFDA Spiked         C
#> 901  83476_Spiked_A       83476   13.17   7735   NR Spiked         A
#> 902  83476_Spiked_A       83476   13.17   7834   NR Spiked         A
#> 903  83476_Spiked_A       83476   13.17   8077   NR Spiked         A
#> 904  83476_Spiked_B       83476   13.17   8321   NR Spiked         B
#> 905  83476_Spiked_B       83476   13.17   7126   NR Spiked         B
#> 906  83476_Spiked_B       83476   13.17   7712   NR Spiked         B
#> 907  83476_Spiked_C       83476   13.17   7487   NR Spiked         C
#> 908  83476_Spiked_C       83476   13.17   7384   NR Spiked         C
#> 909  83476_Spiked_C       83476   13.17   7805   NR Spiked         C
#> 910  83476_Spiked_A       83476   19.75  65839   aB Spiked         A
#> 911  83476_Spiked_A       83476   19.75  63047   aB Spiked         A
#> 912  83476_Spiked_A       83476   19.75  68878   aB Spiked         A
#> 913  83476_Spiked_B       83476   19.75  69001   aB Spiked         B
#> 914  83476_Spiked_B       83476   19.75  55613   aB Spiked         B
#> 915  83476_Spiked_B       83476   19.75  60536   aB Spiked         B
#> 916  83476_Spiked_C       83476   19.75  65597   aB Spiked         C
#> 917  83476_Spiked_C       83476   19.75  66320   aB Spiked         C
#> 918  83476_Spiked_C       83476   19.75  65378   aB Spiked         C
#> 919  83476_Spiked_A       83476   19.75 125314 CFDA Spiked         A
#> 920  83476_Spiked_A       83476   19.75 139555 CFDA Spiked         A
#> 921  83476_Spiked_A       83476   19.75 114593 CFDA Spiked         A
#> 922  83476_Spiked_B       83476   19.75 144669 CFDA Spiked         B
#> 923  83476_Spiked_B       83476   19.75 128917 CFDA Spiked         B
#> 924  83476_Spiked_B       83476   19.75 118717 CFDA Spiked         B
#> 925  83476_Spiked_C       83476   19.75 126129 CFDA Spiked         C
#> 926  83476_Spiked_C       83476   19.75 121113 CFDA Spiked         C
#> 927  83476_Spiked_C       83476   19.75 135302 CFDA Spiked         C
#> 928  83476_Spiked_A       83476   19.75   7623   NR Spiked         A
#> 929  83476_Spiked_A       83476   19.75   7608   NR Spiked         A
#> 930  83476_Spiked_A       83476   19.75   7571   NR Spiked         A
#> 931  83476_Spiked_B       83476   19.75   8181   NR Spiked         B
#> 932  83476_Spiked_B       83476   19.75   6843   NR Spiked         B
#> 933  83476_Spiked_B       83476   19.75   8605   NR Spiked         B
#> 934  83476_Spiked_C       83476   19.75   7689   NR Spiked         C
#> 935  83476_Spiked_C       83476   19.75   8678   NR Spiked         C
#> 936  83476_Spiked_C       83476   19.75   7246   NR Spiked         C
#> 937  83476_Spiked_A       83476   29.63  68604   aB Spiked         A
#> 938  83476_Spiked_A       83476   29.63  74062   aB Spiked         A
#> 939  83476_Spiked_A       83476   29.63  67988   aB Spiked         A
#> 940  83476_Spiked_B       83476   29.63  66802   aB Spiked         B
#> 941  83476_Spiked_B       83476   29.63  79943   aB Spiked         B
#> 942  83476_Spiked_B       83476   29.63  59717   aB Spiked         B
#> 943  83476_Spiked_C       83476   29.63  76337   aB Spiked         C
#> 944  83476_Spiked_C       83476   29.63  75400   aB Spiked         C
#> 945  83476_Spiked_C       83476   29.63  69692   aB Spiked         C
#> 946  83476_Spiked_A       83476   29.63 124331 CFDA Spiked         A
#> 947  83476_Spiked_A       83476   29.63 129929 CFDA Spiked         A
#> 948  83476_Spiked_A       83476   29.63 127335 CFDA Spiked         A
#> 949  83476_Spiked_B       83476   29.63 132082 CFDA Spiked         B
#> 950  83476_Spiked_B       83476   29.63 119507 CFDA Spiked         B
#> 951  83476_Spiked_B       83476   29.63 127949 CFDA Spiked         B
#> 952  83476_Spiked_C       83476   29.63 135568 CFDA Spiked         C
#> 953  83476_Spiked_C       83476   29.63 136831 CFDA Spiked         C
#> 954  83476_Spiked_C       83476   29.63 122344 CFDA Spiked         C
#> 955  83476_Spiked_A       83476   29.63   6824   NR Spiked         A
#> 956  83476_Spiked_A       83476   29.63   6867   NR Spiked         A
#> 957  83476_Spiked_A       83476   29.63   7119   NR Spiked         A
#> 958  83476_Spiked_B       83476   29.63   6672   NR Spiked         B
#> 959  83476_Spiked_B       83476   29.63   7003   NR Spiked         B
#> 960  83476_Spiked_B       83476   29.63   6308   NR Spiked         B
#> 961  83476_Spiked_C       83476   29.63   7804   NR Spiked         C
#> 962  83476_Spiked_C       83476   29.63   7092   NR Spiked         C
#> 963  83476_Spiked_C       83476   29.63   7235   NR Spiked         C
#> 964  83476_Spiked_A       83476   44.44  40251   aB Spiked         A
#> 965  83476_Spiked_A       83476   44.44  39137   aB Spiked         A
#> 966  83476_Spiked_A       83476   44.44  37177   aB Spiked         A
#> 967  83476_Spiked_B       83476   44.44  41200   aB Spiked         B
#> 968  83476_Spiked_B       83476   44.44  42259   aB Spiked         B
#> 969  83476_Spiked_B       83476   44.44  38002   aB Spiked         B
#> 970  83476_Spiked_C       83476   44.44  36278   aB Spiked         C
#> 971  83476_Spiked_C       83476   44.44  44377   aB Spiked         C
#> 972  83476_Spiked_C       83476   44.44  39205   aB Spiked         C
#> 973  83476_Spiked_A       83476   44.44 115462 CFDA Spiked         A
#> 974  83476_Spiked_A       83476   44.44 111178 CFDA Spiked         A
#> 975  83476_Spiked_A       83476   44.44 106912 CFDA Spiked         A
#> 976  83476_Spiked_B       83476   44.44 107867 CFDA Spiked         B
#> 977  83476_Spiked_B       83476   44.44 102550 CFDA Spiked         B
#> 978  83476_Spiked_B       83476   44.44  99268 CFDA Spiked         B
#> 979  83476_Spiked_C       83476   44.44 110730 CFDA Spiked         C
#> 980  83476_Spiked_C       83476   44.44 116714 CFDA Spiked         C
#> 981  83476_Spiked_C       83476   44.44 101750 CFDA Spiked         C
#> 982  83476_Spiked_A       83476   44.44   5767   NR Spiked         A
#> 983  83476_Spiked_A       83476   44.44   6282   NR Spiked         A
#> 984  83476_Spiked_A       83476   44.44   6423   NR Spiked         A
#> 985  83476_Spiked_B       83476   44.44   5806   NR Spiked         B
#> 986  83476_Spiked_B       83476   44.44   7378   NR Spiked         B
#> 987  83476_Spiked_B       83476   44.44   6158   NR Spiked         B
#> 988  83476_Spiked_C       83476   44.44   6878   NR Spiked         C
#> 989  83476_Spiked_C       83476   44.44   5912   NR Spiked         C
#> 990  83476_Spiked_C       83476   44.44   5749   NR Spiked         C
#> 991  83476_Spiked_A       83476   66.67  14562   aB Spiked         A
#> 992  83476_Spiked_A       83476   66.67  13765   aB Spiked         A
#> 993  83476_Spiked_A       83476   66.67  14871   aB Spiked         A
#> 994  83476_Spiked_B       83476   66.67  15512   aB Spiked         B
#> 995  83476_Spiked_B       83476   66.67  14907   aB Spiked         B
#> 996  83476_Spiked_B       83476   66.67  14651   aB Spiked         B
#> 997  83476_Spiked_C       83476   66.67  14910   aB Spiked         C
#> 998  83476_Spiked_C       83476   66.67  15124   aB Spiked         C
#> 999  83476_Spiked_C       83476   66.67  14214   aB Spiked         C
#> 1000 83476_Spiked_A       83476   66.67  45683 CFDA Spiked         A
#> 1001 83476_Spiked_A       83476   66.67  37821 CFDA Spiked         A
#> 1002 83476_Spiked_A       83476   66.67  42910 CFDA Spiked         A
#> 1003 83476_Spiked_B       83476   66.67  39625 CFDA Spiked         B
#> 1004 83476_Spiked_B       83476   66.67  43048 CFDA Spiked         B
#> 1005 83476_Spiked_B       83476   66.67  41345 CFDA Spiked         B
#> 1006 83476_Spiked_C       83476   66.67  43324 CFDA Spiked         C
#> 1007 83476_Spiked_C       83476   66.67  43175 CFDA Spiked         C
#> 1008 83476_Spiked_C       83476   66.67  40802 CFDA Spiked         C
#> 1009 83476_Spiked_A       83476   66.67   3953   NR Spiked         A
#> 1010 83476_Spiked_A       83476   66.67   3676   NR Spiked         A
#> 1011 83476_Spiked_A       83476   66.67   3865   NR Spiked         A
#> 1012 83476_Spiked_B       83476   66.67   3587   NR Spiked         B
#> 1013 83476_Spiked_B       83476   66.67   3760   NR Spiked         B
#> 1014 83476_Spiked_B       83476   66.67   3701   NR Spiked         B
#> 1015 83476_Spiked_C       83476   66.67   3629   NR Spiked         C
#> 1016 83476_Spiked_C       83476   66.67   3758   NR Spiked         C
#> 1017 83476_Spiked_C       83476   66.67   3796   NR Spiked         C
#> 1018 83476_Spiked_A       83476     100   7160   aB Spiked         A
#> 1019 83476_Spiked_A       83476     100   7072   aB Spiked         A
#> 1020 83476_Spiked_A       83476     100   7007   aB Spiked         A
#> 1021 83476_Spiked_B       83476     100   7798   aB Spiked         B
#> 1022 83476_Spiked_B       83476     100   6969   aB Spiked         B
#> 1023 83476_Spiked_B       83476     100   6588   aB Spiked         B
#> 1024 83476_Spiked_C       83476     100   6948   aB Spiked         C
#> 1025 83476_Spiked_C       83476     100   7980   aB Spiked         C
#> 1026 83476_Spiked_C       83476     100   7604   aB Spiked         C
#> 1027 83476_Spiked_A       83476     100   4345 CFDA Spiked         A
#> 1028 83476_Spiked_A       83476     100   3764 CFDA Spiked         A
#> 1029 83476_Spiked_A       83476     100   4518 CFDA Spiked         A
#> 1030 83476_Spiked_B       83476     100   3967 CFDA Spiked         B
#> 1031 83476_Spiked_B       83476     100   4375 CFDA Spiked         B
#> 1032 83476_Spiked_B       83476     100   4683 CFDA Spiked         B
#> 1033 83476_Spiked_C       83476     100   4715 CFDA Spiked         C
#> 1034 83476_Spiked_C       83476     100   4053 CFDA Spiked         C
#> 1035 83476_Spiked_C       83476     100   3823 CFDA Spiked         C
#> 1036 83476_Spiked_A       83476     100   2843   NR Spiked         A
#> 1037 83476_Spiked_A       83476     100   2377   NR Spiked         A
#> 1038 83476_Spiked_A       83476     100   2583   NR Spiked         A
#> 1039 83476_Spiked_B       83476     100   2419   NR Spiked         B
#> 1040 83476_Spiked_B       83476     100   2494   NR Spiked         B
#> 1041 83476_Spiked_B       83476     100   2872   NR Spiked         B
#> 1042 83476_Spiked_C       83476     100   2536   NR Spiked         C
#> 1043 83476_Spiked_C       83476     100   2566   NR Spiked         C
#> 1044 83476_Spiked_C       83476     100   2206   NR Spiked         C
#> 1045 83476_Spiked_A       83476   Blank   5124   aB Spiked         A
#> 1046 83476_Spiked_A       83476   Blank   5124   aB Spiked         A
#> 1047 83476_Spiked_B       83476   Blank   5758   aB Spiked         B
#> 1048 83476_Spiked_B       83476   Blank   5436   aB Spiked         B
#> 1049 83476_Spiked_C       83476   Blank   5747   aB Spiked         C
#> 1050 83476_Spiked_C       83476   Blank   5438   aB Spiked         C
#> 1051 83476_Spiked_A       83476   Blank   3965 CFDA Spiked         A
#> 1052 83476_Spiked_A       83476   Blank   3689 CFDA Spiked         A
#> 1053 83476_Spiked_B       83476   Blank   4025 CFDA Spiked         B
#> 1054 83476_Spiked_B       83476   Blank   3902 CFDA Spiked         B
#> 1055 83476_Spiked_C       83476   Blank   4059 CFDA Spiked         C
#> 1056 83476_Spiked_C       83476   Blank   4385 CFDA Spiked         C
#> 1057 83476_Spiked_A       83476   Blank   1612   NR Spiked         A
#> 1058 83476_Spiked_A       83476   Blank   1559   NR Spiked         A
#> 1059 83476_Spiked_B       83476   Blank   1629   NR Spiked         B
#> 1060 83476_Spiked_B       83476   Blank   1549   NR Spiked         B
#> 1061 83476_Spiked_C       83476   Blank   1744   NR Spiked         C
#> 1062 83476_Spiked_C       83476   Blank   1494   NR Spiked         C
#> 1063 83476_Spiked_A       83476 Control 138321   aB Spiked         A
#> 1064 83476_Spiked_A       83476 Control 148968   aB Spiked         A
#> 1065 83476_Spiked_B       83476 Control 135487   aB Spiked         B
#> 1066 83476_Spiked_B       83476 Control 141948   aB Spiked         B
#> 1067 83476_Spiked_C       83476 Control 150146   aB Spiked         C
#> 1068 83476_Spiked_C       83476 Control 130872   aB Spiked         C
#> 1069 83476_Spiked_A       83476 Control 237538 CFDA Spiked         A
#> 1070 83476_Spiked_A       83476 Control 244821 CFDA Spiked         A
#> 1071 83476_Spiked_B       83476 Control 233341 CFDA Spiked         B
#> 1072 83476_Spiked_B       83476 Control 215707 CFDA Spiked         B
#> 1073 83476_Spiked_C       83476 Control 225588 CFDA Spiked         C
#> 1074 83476_Spiked_C       83476 Control 256360 CFDA Spiked         C
#> 1075 83476_Spiked_A       83476 Control   9462   NR Spiked         A
#> 1076 83476_Spiked_A       83476 Control   8166   NR Spiked         A
#> 1077 83476_Spiked_B       83476 Control   8930   NR Spiked         B
#> 1078 83476_Spiked_B       83476 Control   8177   NR Spiked         B
#> 1079 83476_Spiked_C       83476 Control   8869   NR Spiked         C
#> 1080 83476_Spiked_C       83476 Control   9058   NR Spiked         C
```

At first glance this dataset seems manageable, but it consists of 45
subsets of data.

Current approaches would require us to fragment the dataset and analyze
each one manually.

`toxdrc` offers another way to do this, through `runtoxdrc()`, which
analyzes all of them in one function.

``` r
analyzed_data <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  qc = toxdrc_qc(), # uses defualt arguments, which can be overwritten. This controls testing for solvent effects, outlier testing, and CV calculations. Use ?toxdrc_qc() for more info.
  normalization = toxdrc_normalization(
    # here we specify to blank correct and normalize, instead of using default values. Only have to specify the arguments that do not use the default value. Use ?toxdrc_normalization() for more info.
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  toxicity = toxdrc_toxicity(), # uses defualt arguments, which can be overwritten. This controls how toxicity is determined. Use ?toxdrc_toxicity() for more info.
  modelling = toxdrc_modelling(
    # Use ?toxdrc_modelling() for more info.
    quiet = TRUE
  )
)

analyzed_data
#> $`83167.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
```

Currently working on other functions to view the plots and combine the
output into useable, readable formats.
