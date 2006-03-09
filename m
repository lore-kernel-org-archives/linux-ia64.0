From: Jes Sorensen <jes@sgi.com>
Date: Thu, 09 Mar 2006 09:50:25 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <yq0r75c2bha.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <matthew@wil.cx> writes:

Matthew> On Wed, Mar 08, 2006 at 11:54:26AM -0800, Luck, Tony wrote:
>> Bjorn Helgaas: [IA64] don't report !sn2 or !summit hardware as an
>> error [IA64] SGI SN drivers: don't report !sn2 hardware as an error

Matthew> I thought hch solved this by fixing the initcall code to not
Matthew> treat -ENODEV as an error worthy of reporting?

I agree, I think it's a bit unfortunate this was pushed upstream
before a decision was made.

IMHO it's correct to report -ENODEV if no device is present and have a
module auto-unload in that case.

Cheers,
Jes
