From: Andreas Hirstius <Andreas.Hirstius@cern.ch>
Date: Tue, 05 Apr 2005 18:11:51 +0000
Subject: Serious performance degradation on a RAID with kernel 2.6.11
Message-Id: <4252D4E7.1020806@cern.ch>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,


We have a rx4640 with 3x 3Ware 9500 SATA controllers and 24x WD740GD HDD 
in a software RAID0 configuration (using md).
With kernel 2.6.11 the read performance on the md is reduced by a factor 
of 20 (!!) compared to previous kernels.
The write rate to the md doesn't change!! (it actually improves a bit).

The config for the kernels are basically identical.

Here is some vmstat output:

kernel 2.6.9: ~1GB/s read
procs                      memory      swap          io     
system         cpu
r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy 
wa id
1  1      0  12672   6592 15914112    0    0 1081344    56 15719  1583  
0 11 14 74
1  0      0  12672   6592 15915200    0    0 1130496     0 15996  1626  
0 11 14 74
0  1      0  12672   6592 15914112    0    0 1081344     0 15891  1570  
0 11 14 74
0  1      0  12480   6592 15914112    0    0 1081344     0 15855  1537  
0 11 14 74
1  0      0  12416   6592 15914112    0    0 1130496     0 16006  1586  
0 12 14 74


kernel 2.6.11: ~55MB/s read
procs                      memory      swap          io     
system         cpu
r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy 
wa id
1  1      0  24448  37568 15905984    0    0 56934     0 5166  1862  0  
1 24 75
0  1      0  20672  37568 15909248    0    0 57280     0 5168  1871  0  
1 24 75
0  1      0  22848  37568 15907072    0    0 57306     0 5173  1874  0  
1 24 75
0  1      0  25664  37568 15903808    0    0 57190     0 5171  1870  0  
1 24 75
0  1      0  21952  37568 15908160    0    0 57267     0 5168  1871  0  
1 24 75


Because the filesystem might have an impact on the measurement, a simple 
"dd" on /dev/md0 was used to get information about the actual 
performance. This also opens the possibility to test with block sizes 
larger than the page size.
And it appears that the performance with kernel 2.6.11 is closely 
related to the block size.
For example if the block size is exactly a multiple (>2) of the page 
size the performance is back to ~1.1GB/s.
The general behaviour is a bit more complicated:  

   1. bs <= 1.5 * ps : ~27-57MB/s (differs with ps)
   2. bs > 1.5 * ps && bs < 2 * ps : rate increases to max. rate
   3. bs = n * ps ; (n >= 2) : ~1.1GB/s (= max. rate)
   4. bs > n * ps && bs < ~(n+0.5) * ps ; (n > 2) : ~27-70MB/s (differs 
with ps)
   5. bs > ~(n+0.5) * ps && bs < (n+1) * ps ; (n > 2) : increasing rate 
in several, more or
       less, distinct steps (e.g. 1/3 of max. rate and then 2/3 of max 
rate for 64k pages)

I've tested all four page sizes (4k, 8k, 16k and 64k) and the pattern is 
always the same!!

With kernel 2.6.9 the read rate is always at ~1.1GB/s, independent of 
the block size.

In order to keep this mail short, I've created a webpage that contains 
all the information and some plots:
http://www.cern.ch/openlab-debugging/raid


 Regards,

    Andreas
