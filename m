From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 05 Nov 2003 23:18:29 +0000
Subject: RE: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106807433606850@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Dentry cache hash table entries: 33554432 (order: 14, 268435456 bytes)
> Inode-cache hash table entries: 33554432 (order: 14, 268435456 bytes)
> IP: routing cache hash table of 8388608 buckets, 131072Kbytes
> TCP: Hash tables configured (established 67108864 bind 65536)
> swapper: page allocation failure. order:17, mode:0x20

Does these hash tables really need to that big? 33 million dentry and
inode
entry? Same thing with network, unless the machine is loaded with
several
gigabit cards, these hash table seems to be exceedingly large.
