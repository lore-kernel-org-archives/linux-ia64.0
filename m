From: Yasunori Goto <ygoto@fsw.fujitsu.com>
Date: Thu, 02 Oct 2003 02:57:48 +0000
Subject: Idea of Memory hotplug
Message-Id: <marc-linux-ia64-106506350506610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Dear all.

I'm going to enhance some features in Linux that could replace
highly reliable/available system like mainframe and UNIX.
My first interest is Memory hotplug functionality.
Hot remove memory is not only needed for online memory maintenance
but also necessary for the dynamic re-partitioning(*) functionality,
which many mainframe systems already support.

(*) Memory and CPUs of a system can be divided into several
independent sets to form multiple independent computers
("partitioning"). Re-partitioning means moving separation boundary of
memory (and CPUs, maybe) to improve resource utilization.

My idea is followings.

    - Basically, swap out memory on node which user want to remove.
    - Areas which can't be removed is collected to node 0.
    - Node 0 is NOT hotpluggable, but other nodes are hotpluggable.
    - User area (which is able to be swapped out in many case)
      allocated at ZONE_HIGHMEM now, so we will make it as follows.

  Now
      node 0                 node 1                node 2
    +----------+           +----------+          +----------+
    |          |           |          |          |          |
    |          |-----------|          |----------|          |
    |          |           |          |          |          |
    +----------+           +----------+          +----------+
     ZONE_DMA               ZONE_DMA              ZONE_DMA
     ZONE_NORMAL            ZONE_NORMAL           ZONE_NORMAL
     ZONE_HIGHMEM           ZONE_HIGHMEM          ZONE_HIGHMEM


  We want to make like this.
      node 0                 node 1                node 2
     (unhotpluggable)      (hotpluggable)        (hotpluggable)
    +----------+           +----------+          +----------+
    |          |           |          |          |          |
    |          |-----------|          |----------|          |
    |          |           |          |          |          |
    +----------+           +----------+          +----------+
     ZONE_DMA
     ZONE_NORMAL              
                           ZONE_HIGHMEM          ZONE_HIGHMEM

Todo list:
  - Pages which without secondary store.
    The page caches of virtural file system like sysfs.
  - Huge TLB page which cannot be page out.
  - Pages which need time to become free.
    Pages which are being sent by sendfile, or accessed by NFS.
  - DMA mapping area.
  - And so on....

I wish I will have comments from anybody.
And,I want to find other appropriate mailing-list 
about this discussion if you know.

Best regards.


-- 
Yasunori Goto <ygoto at fsw.fujitsu.com>


