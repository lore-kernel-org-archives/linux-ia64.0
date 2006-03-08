From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Mar 2006 20:47:34 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05E8B8F5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Wed, Mar 08, 2006 at 11:54:26AM -0800, Luck, Tony wrote:
>> Bjorn Helgaas:
>>       [IA64] don't report !sn2 or !summit hardware as an error
>>       [IA64] SGI SN drivers: don't report !sn2 hardware as an error
>
>I  thought hch solved  this by  fixing  the initcall  code  to  not
>treat -ENODEV as an error  worthy of  reporting?

That's what happens when I get far, far behind on LKML.  I've found
traces of the threads ... though none by hch, and no clear agreement
about whether 0 or -ENODEV is right.  Some of this code is linked
into the ia64 generic kernel by default, so I'm leaning a little
towards Bjorn's position that we shouldn't be returning an error.

-Tony
