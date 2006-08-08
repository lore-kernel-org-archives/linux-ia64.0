From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 08 Aug 2006 18:52:41 +0000
Subject: RE: Silent data corruption caused by XPC V2.
Message-Id: <A29F7A5700A7EA4380E08C1F68C3B6D8B256CF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Seems the following part is missed in your patch:

--- arch/ia64/sn/kernel/xpc_main.c      2006-02-13 12:35:03.000000000
-0800
+++ arch/ia64/sn/kernel/xpc_main.c.new   2006-08-08 11:47:03.000000000
-0700
@@ -1374,6 +1374,7 @@ xpc_init(void)
                complete(&xpc_discovery_exited);

                xpc_do_exit(xpcUnloading);
+               kfree(xpc_remote_copy_buffer_base);
                return -EBUSY;
        }

Thanks.

-Fenghua
