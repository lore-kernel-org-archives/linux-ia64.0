From: Jack Steiner <steiner@sgi.com>
Date: Tue, 04 Nov 2003 00:55:24 +0000
Subject: percpu data for non-existant cpus
Message-Id: <marc-linux-ia64-106790736528585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It was neccessary in 2.4 to allocate cpu_data areas for
non-existent cpus. I forget where, but some generic
initialization code expected to be able to reference cpu_data 
for all cpus up to NR_CPUS.

Does 2.6 have the same requirement or can I allocate cpu_data
areas only for cpus that exist or might exist (cpu_possible()).


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


