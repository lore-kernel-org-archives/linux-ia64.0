From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 06 Oct 2004 06:20:56 +0000
Subject: [RFC/PATCH]  pfn_valid() more generic : intro[0/2]
Message-Id: <41638EC8.9090901@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

Hi,

ia64's ia64_pfn_valid() uses get_user() for checking whether a page struct
is available or not. I think this is an irregular implementation and following patches
are a more generic replacement, careful_pfn_valid(). It uses 2 level table.

Core Algorithm
==
1st level, pfn_validmap[] has index to 2nd level table.
2nd level table is consists of (start, end) entries of valid pfns.

careful_pfn_valid(pfn)
  -> pfn_validmap[(pfn >> PFN_VALID_MAPSHIFT)] = entry
     if (entry =  ALL_VALID) return 1
     if (entry =  ALL_INVALID)  return 0

      -> check 2nd level,
     info = pfn_valid_info_table + entry.
     while(info->start_pfn < pfn) {
          if((info->start_pfn <= pfn) && (info->end_pfn > pfn))
                     return 0;
               info++;
     }
     return 1;
==
sizeof(entry) is 2 bytes and each entry covers 1GB with current config(16k pages).

Here is kernbench results on my Tiger4 (Itanium2(1.3GHz) x2, 8 Gbytes memory),pagesizek

Average Optimal -j8 Load Run:
                         Elapsed Time  User Time  System Time  Percent CPU  C/Switch   Sleeps
2.6.9-rc3                 699.906       1322.01     39.336        194        64390    74416.8
2.6.9-rc3 + this_patch    698.478       1321.76     38.228        194        64502    74185

there are no difference :)

For NUMA, I think tables for careful_pfn_valid() should be copied to each node's local memory,
but I haven't implemented it yet.

-- Kame <kamezawa.hiroyu@jp.fujitsu.com>

