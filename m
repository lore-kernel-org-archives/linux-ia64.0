From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Sep 2003 15:49:30 +0000
Subject: Re: 2.6 mca_asm.S VA to PA mappings
Message-Id: <marc-linux-ia64-106493756432380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106490506400881@msgid-missing>
In-Reply-To: <marc-linux-ia64-106490506400881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 30 Sep 2003 08:42:10 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>> ia64_mca_bspstore	(V=0xe000000004d5a6d0)
>> DATA_VA_TO_PA		(P=0x0000013014d5a6d0)
>> DATA_PA_TO_VA		(V=0xe000013014d5a6d0)
>> 
>> With the 2.4 alt.dtlb handler that still works, although it is
>> confusing to C code which needs to access the RSE data in
>> ia64_mca_bspstore.  I doubt that DATA_PA_TO_VA will work if the kernel
>> is in region 5.
>
>Same thing, we need LOAD_PHYSICAL there too.

Slight confusion.  DATA_VA_TO_PA needs to be replaced by LOAD_PHYSICAL,
but what replaces DATA_PA_TO_VA in a non-identity mapped kernel?

bspstore needs a valid virtual address before calling the C code.  If
the asm code was told the original virtual address (ia64_mca_bspstore)
then DATA_PA_TO_VA could convert ar.bspstore from P to V.  Without that
hint, I see no way of mapping P to V for an arbitrary address held in a
register.

