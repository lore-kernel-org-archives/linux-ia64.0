From: Mario Smarduch <cms063@email.mot.com>
Date: Mon, 26 Apr 2004 18:57:45 +0000
Subject: cacheble to uncachble change
Message-Id: <408D5C58.E07A5FBE@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there support in IA64 kernel to change a memory mapping from
cacheble to uncacheble  attribute. By support I mean one function
which can accept an addr start/range,  make sure in-transit
cache data/prefetch  hits are synced and upon return gurantee
no CPU has any stale data in its caches and after installing the new
attribute memory is guranteed synchronized. Or is a combonition
of functions/macros required?

- Mario


