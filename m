From: Nathan Thomas <nthomas@redhat.com>
Date: Tue, 20 Feb 2001 20:05:21 +0000
Subject: [Linux-ia64] RE: more info please (fwd)
Message-Id: <marc-linux-ia64-105590693005173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone else seen a problem with apps not running on multiple
processors with the upgrade to 2.40-0.99.11smp?  

Running on older versions of Red Hat 7.1 the app appears to get adequate
CPU usage, but under the latest version it drops to about 25% of CPU
utilization, indicating it's only running on one of the 4 CPUs.  It just
looks like the threads aren't executing in parallel.

Buffers seem to fill and processes disconnect, so the app definitely needs
more CPU time...

Any thoughts?

nate

-- 
Nathan Thomas
Senior Sales Engineer
nthomas@redhat.com
Work:(919)547-0012x393
Cell:(919)949-3882




