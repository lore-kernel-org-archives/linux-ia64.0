From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 18 Dec 2006 19:23:29 +0000
Subject: RE: [PATCH] IA64: alignment bug in ldscript
Message-Id: <000001c722d9$ffb63f90$e834030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <458683CF.8030606@openvz.org>
References: <458683CF.8030606@openvz.org>
In-Reply-To: <458683CF.8030606@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Kirill Korotaev' <dev@openvz.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Alexey Kuznetsov <alexey@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org

Kirill Korotaev wrote on Monday, December 18, 2006 4:05 AM
> [IA64] bug in ldscript (mainstream)
> 
> Occasionally, in mainstream number of fsys entries is even.

Is it a typo on "fsys entries is even"?

If not, then this change log is misleading. It is the instruction
patch list of FSYS_RETURN that can potentially cause other data
structures to be out of alignment. And number of FSYS_RETURN call
site will not necessarily match number of fsys entry.


> In OpenVZ it is odd and we get misaligned kernel image,
> which does not boot.

Otherwise, the patch looks fine to me.
