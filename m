From: Bob Picco <bob.picco@hp.com>
Date: Thu, 16 Jun 2005 13:28:19 +0000
Subject: [PATCH 0/4] V3 ia64 SPARSEMEM
Message-Id: <20050616132819.GP23911@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

ChangeLog V2:
	Jesse's review input has been applied to patches 3 and 4.
	These were all cosmetic changes.
ChangeLog V3:
	This patchset has changes for building ia64 with SPARSEMEM +
	ARCH_SPARSEMEM_EXTREME config options.  The configuration options
	SECTION_BITS and PHYSICAL_MEMORY_BITS have been removed and are
	like other arches (not configurable).  

	This patchset depends on SPARSEMEM EXTREME patches submitted to -mm.
	The -mm patch sparsemem-extreme.patch and all those which it depends
	on are required. EXTREME has introduced a two dimensional array
	to SPARSEMEM. The two level layout should reduce memory requirements
	for extremely sparse memory at the expense of an additional load
	and shift when fetching the section map for a page frame.

	The only C code change since V2 is in patch 4.  SPARSEMEM's 
	routine memory_present, for identifying a section with memory, is
	called in paging_init instead of find_memory. This is required
	because EXTREME uses the bootmem allocator for the root level
	allocations in the new two level layout scheme. 
	
	I have gathered OSDL aim7 data on an rx2600 4Gb of memory and two
	CPUs.  The data is for SPARSEMEM+EXTREME and DISCONTIG+VIRTUAL_MEM_MAP.
	This obviously isn't conclusive data for the adoption of ia64
	SPARSEMEM but does demonstrate no degradation on a small server.  I'll 
	need Jack's help to gather more supporting performance data.

This is a series of patches which enable SPARSEMEM for ia64.  It's against
rc4-mm2.  The patches have been tested against memory configurations FLATMEM,
DISCONTIG and SPARSEMEM+EXTREME.  This includes NUMA simulated hardware, rx2600
and HPSIM.  An early version of ia64 with SPARSEMEM was tested by Jesse. It
would be optimal to have another test pass on SGI NUMA hardware.

thanks,

bob

SPARSEMEM+EXTREME AIM data

REAIM Workload
Times are in seconds - Child times from tms.cstime and tms.cutime

Num     Parent   Child   Child  Jobs per   Jobs/min/  Std_dev  Std_dev  JTI
Forked  Time     SysTime UTime   Minute     Child      Time     Percent
1       0.07     0.02    0.03    92727.27   92727.27   0.00     0.00     100
201     5.60     4.21    7.00    219782.03  1093.44    1.23     30.67    69
401     11.18    8.34    14.04   219470.58  547.31     2.42     32.91    67
601     16.75    12.67   20.88   219576.14  365.35     3.49     26.09    73
801     22.33    16.77   27.96   219501.19  274.03     4.35     22.98    77
1001    27.93    20.96   34.96   219377.62  219.16     6.12     25.20    74
1201    33.49    25.10   41.99   219452.42  182.72     6.57     21.70    78
1401    39.20    29.49   48.89   218699.66  156.10     10.58    31.87    68
1601    44.85    33.47   56.04   218454.47  136.45     8.21     23.71    76
1801    50.35    37.73   62.99   218896.99  121.54     8.40     19.84    80
2225    62.21    46.91   77.65   218884.12  98.37      14.08    25.27    74
2649    74.07    55.93   92.40   218872.42  82.62      15.24    22.34    77
Max Jobs per Minute 219782.03


DISCONTIG+VIRTUAL_MEM_MAP aim data

REAIM Workload
Times are in seconds - Child times from tms.cstime and tms.cutime

Num     Parent   Child   Child  Jobs per   Jobs/min/  Std_dev  Std_dev  JTI
Forked  Time     SysTime UTime   Minute     Child      Time     Percent 
1       0.07     0.02    0.04    86197.18   86197.18   0.00     0.00     100  
201     5.60     4.20    7.02    219821.30  1093.64    1.01     20.84    79   
401     11.20    8.31    14.09   219215.72  546.67     2.68     29.89    70   
601     16.78    12.58   21.01   219196.66  364.72     3.10     22.84    77   
801     22.36    16.79   27.98   219265.55  273.74     4.79     26.12    73   
1001    27.99    21.06   34.93   218891.63  218.67     5.58     24.21    75   
1201    33.72    24.99   42.25   217975.09  181.49     7.13     28.54    71   
1401    39.39    29.42   49.06   217655.93  155.36     8.65     34.26    65   
1601    44.91    33.62   56.02   218152.91  136.26     8.67     28.35    71   
1801    50.45    37.70   63.12   218480.45  121.31     9.05     25.04    74   
2225    62.65    46.75   77.96   217350.36  97.69      13.01    31.95    68   
2649    74.21    55.64   92.77   218468.34  82.47      16.29    25.43    74   
Max Jobs per Minute 219821.30

