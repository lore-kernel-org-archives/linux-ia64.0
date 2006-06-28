From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 28 Jun 2006 10:44:00 +0000
Subject: Re: [PATCH] fix prom revision checks in SN kernel
Message-Id: <44A25D70.9030106@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606271946.MAA19328@google.engr.sgi.com>
In-Reply-To: <200606271946.MAA19328@google.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 ...
+	if (is_shub1() && sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {

... asm/sn/sn_feature_sets.h, line 33 ...

P.
>   
