From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 08 Aug 2000 02:19:17 +0000
Subject: Re: [Linux-ia64] gnu-efi-0.9 released
Message-Id: <marc-linux-ia64-105590678205271@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205270@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205270@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Aug 2000 18:59:43 -0700 (PDT), 
Stephane Eranian <eranian@frankl.hpl.hp.com> wrote:
>To get the initrd support to work ...

Kernels >= 2.4.0-test6-pre3 need the latest version of mkinitrd, the
module directory structure changed.  modutils 2.3.14 would be a good
idea for 2.4.0-test6 kernels.


