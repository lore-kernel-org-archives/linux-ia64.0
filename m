From: Jack Steiner <steiner@sgi.com>
Date: Fri, 18 Nov 2005 05:23:17 +0000
Subject: Re: 2.6.14 boots on sgi altix?
Message-Id: <20051118052317.GA22784@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200511180316.jAI3G9g06785@unix-os.sc.intel.com>
In-Reply-To: <200511180316.jAI3G9g06785@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 17, 2005 at 07:16:07PM -0800, Chen, Kenneth W wrote:
> Is there something special I need to do to boot 2.6.14 on SGI
> altix machine?  I took 7 day old 2.6.14.2 kernel source, and
> did the following:

Give this a try. Line numbers may be slightly off - I have a different
version of the tree but this _should_ apply. Untested ...



Index: linux/include/asm/sn/sn_sal.h
=================================--- linux.orig/include/asm/sn/sn_sal.h	2005-11-03 18:07:57.000000000 -0600
+++ linux/include/asm/sn/sn_sal.h	2005-11-17 22:28:22.607430600 -0600
@@ -1018,6 +1018,24 @@ ia64_sn_get_sn_info(int fc, u8 *shubtype
 	ret_stuff.v2 = 0;
 	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SN_INFO, fc, 0, 0, 0, 0, 0, 0);
 
+/***** BEGIN HACK - temp til old proms no longer supported ********/
+	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
+		int nasid = get_sapicid() & 0xfff;;
+#define SH_SHUB_ID_NODES_PER_BIT_MASK 0x001f000000000000UL                                               
+#define SH_SHUB_ID_NODES_PER_BIT_SHFT 48                                                               
+		if (shubtype) *shubtype = 0;
+		if (nasid_bitmask) *nasid_bitmask = 0x7ff;
+		if (nasid_shift) *nasid_shift = 38;
+		if (systemsize) *systemsize = 10;
+		if (sharing_domain_size) *sharing_domain_size = 8;
+		if (partid) *partid = sn_partition_serial_number;
+		if (coher) *coher = nasid >> 9;
+		if (reg) *reg = (HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_SHUB_ID)) & SH_SHUB_ID_NODES_PER_BIT_MASK) >>
+			SH_SHUB_ID_NODES_PER_BIT_SHFT;
+		return 0;
+	}
+/***** END HACK *******/
+
 	if (ret_stuff.status < 0)
 		return ret_stuff.status;
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


