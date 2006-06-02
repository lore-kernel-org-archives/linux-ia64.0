From: "Ken'ichi Ohmichi" <oomichi@mxs.nes.nec.co.jp>
Date: Fri, 02 Jun 2006 05:32:00 +0000
Subject: Re: [Fastboot] Where is the latest patch of kdump for ia64?
Message-Id: <20060602143200oomichi@mail.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

2006/05/31 18:40:54 +0900, Takao Indoh <indou.takao@soft.fujitsu.com> wrote:
>I am interested in kdump on ia64 and I am looking for the latest
>patch of kdump.
I found ia64-kdump patch from Zou Nan hai. Isn't this patch latest?
http://lists.osdl.org/pipermail/fastboot/2006-March/002577.html

I tested this patch on the system. As the result, the system froze while
switching to second kernel (in relocate_new_kernel).
Can you do kdump with this patch?

Test environment:
  CPU        : Itanium 2, 1.0GHz
  Memory     : 6GB
  Kernel     : linux-2.6.15
                + ia64-kexec-kdump-2.6.15.patch (2006/03/14 from Zou Nan hai)
  Kexec-tools: kexec-tools-1.101
                + kexec-tools-1.101-kdump.patch (2006/03/14 from Zou Nan hai)
                + ia64-kexec-tool-kdump.patch   (2006/03/14 from Zou Nan hai)
  Package    : RHEL4AS-U3

Thanks
Ken'ichi Ohmichi
