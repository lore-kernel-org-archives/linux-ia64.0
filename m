From: Jes Sorensen <jes@trained-monkey.org>
Date: Mon, 16 Jan 2006 08:21:01 +0000
Subject: Re: [PATCH] RESEND - SN: Add initial ACPI support
Message-Id: <yq01wz8vb0y.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060115182308.22089.1201.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20060115182308.22089.1201.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

>>>>> "John" = John Keller <jpk@sgi.com> writes:

John> Please disregard the earlier (01/14) post of this patch.  I
John> erroneously sent out an early version, which was not fully
John> merged with the latest ia64 git tree.

Hi John,

Looks much better. On top of Prarit's comments I just noticed this
one:

+	if (!hubdev->hdi_flush_nasid_list.widget_p)
+		return;
+
+	hubdev->hdi_flush_nasid_list.widget_p +		kzalloc((HUB_WIDGET_ID_MAX + 1) *
+		    sizeof(struct sn_flush_device_kernel *),
+		    GFP_KERNEL);

This doesn't look right, if widget_p is NULL no alloc ortherwise
overwrite it? Did the order get reversed?

Cheers,
Jes
