From: Martin Pool <mbp@sourcefrog.net>
Date: Tue, 28 Oct 2003 05:29:12 +0000
Subject: show_mem panics in 2.4.22
Message-Id: <marc-linux-ia64-106731898417513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm running linux-2.4.22-ia64-030909 on an rx2600.  The show_mem()
function always causes a kernel panic.  This is reached when you send
'SysRq m' or serial 'BREAK m' to find out about used memory, etc.

The problem seems to be that this function is written assuming that
the discontiguous memory scheme is used, but that's not the case in my
configuration.  I see that in 2.6.0-test8 there are two versions of
the function for the contig/discontig cases.  The crash is on the line
that reads through pgdat->node_mem_map.  I'm not sure exactly what is
wrong with that.

-- 
Martin 
