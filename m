From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 27 Mar 2004 00:14:13 +0000
Subject: RE: should ia64_spinlock_contention do backoff?
Message-Id: <200403270014.i2R0EFF07014@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Chris Wedgwood wrote on Fri, March 26, 2004 3:41 PM
> Does anyone have any idea what locks are most heavily contented for
> ia64 right now?

This question is a bit too broad, lock contention highly depends on workload.

For example, I'm doing direct I/O on bunch of block devices, and the dev nodes
sit on reiserfs, this contention shows up:

 79.7% 91.2%   18us(1415us)  449us( 760ms)(57.9%)   2970234  8.8% 91.2%    0%  kernel_flag
 0.00% 92.3%  5.8us(  35us)  689us(  58ms)(0.01%)       298  7.7% 92.3%    0%    __break_lease+0x80
 0.01% 94.3%   23us( 120us)  555us(9106us)(0.01%)       298  5.7% 94.3%    0%    chrdev_open+0x1a0
 0.00% 83.3%  7.6us(  14us)   73us( 344us)(0.00%)         6 16.7% 83.3%    0%    de_put+0x60
 0.00% 92.7%  5.4us(  18us)  633us(  14ms)(0.00%)        41  7.3% 92.7%    0%    default_llseek+0x60
 0.00%  100%  2.9us( 4.2us)   44us(  86us)(0.00%)         2    0%  100%    0%    proc_file_lseek+0x60
 0.00%  100%   32us(  34us) 2523us(7279us)(0.00%)         3    0%  100%    0%    proc_lookup+0x60
 0.00%  100%   14us(  17us)   18us(  24us)(0.00%)         2    0%  100%    0%    reiserfs_commit_write+0xb0
 74.2% 91.2%   16us(1247us)  394us( 292ms)(50.6%)   2959013  8.8% 91.2%    0%    reiserfs_dirty_inode+0xa0
 0.00%  100%  214us( 214us)  106us( 106us)(0.00%)         1    0%  100%    0%    reiserfs_file_release+0x110
 0.00% 50.0%   21us(  34us)   29us(  29us)(0.00%)         2 50.0% 50.0%    0%    reiserfs_readdir+0xb0
 0.01% 92.3%  294us( 369us)  223us(1791us)(0.00%)        13  7.7% 92.3%    0%    reiserfs_write_super+0x60
  5.5% 92.9%  342us(1415us)   16ms( 760ms)( 7.3%)     10516  7.1% 92.9%    0%    schedule+0xe30
 0.00%  100%  4.1us( 7.3us)   27us(  45us)(0.00%)         2    0%  100%    0%    sys_fcntl+0x430
 0.00% 90.9%   14us(  48us)   80us( 254us)(0.00%)        11  9.1% 90.9%    0%    sys_ioctl+0xb0
 0.00% 93.8%   11us(  21us)  191us(2263us)(0.00%)        16  6.2% 93.8%    0%    tty_read+0x170
 0.00% 80.0%   17us(  28us)   21us(  38us)(0.00%)        10 20.0% 80.0%    0%    tty_write+0x3c0


And if my workload does lots of context switch, load balance also shows up
some hot spots.

  1.2%  2.1%  1.9us(  22us)    0us                   426680 97.9%    0%  2.1%  load_balance+0x290
 0.02% 89.3%  2.5us(  44us)  3.3us( 635us)(0.00%)      4582 10.7% 89.3%    0%  load_balance+0x2d0
 0.02%  1.3%  2.9us(  15us)  2.9us( 8.3us)(0.00%)      4582 98.7%  1.3%    0%  load_balance+0x2e0
 0.01% 84.6%  2.1us(  17us)  2.9us(  21us)(0.00%)      4585 15.4% 84.6%    0%  load_balance+0xb60

- Ken


