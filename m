From: "Li, Jack" <jack.li@intel.com>
Date: Sat, 03 Apr 2004 00:07:10 +0000
Subject: RE: [Linux-ia64] elilo-3.0 PXE mode fix
Message-Id: <3AA03342E913FA4BA6D8BD0732BFC74B0547D151@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brett Johnson <mailto:brett@fc.hp.com> wrote on Saturday, April 03, 2004
7:48 AM:

> On Fri, 2004-04-02 at 16:30, Li, Jack wrote:
>> I don't have access to the DHCP server. I can only configure the PXE
>> server which is full under my control. I don't think the
>> dhcpd-pxe.conf can be used for the RedHat PXE server (pxe-0.1-36).
>> Right? 
> 
> No, the config files are quite different.  I don't know if the pxe
> server will boot an ia64 machine, since I've never tried it. 
> Googleing 
> around, I found a sample pxe config in the mandrake docs, which
> actually 
> has the token "IA64EFI" in it.  I have no clue what the token means,
> but 
> it has all the right letters :o)
> 
>   http://clic.mandrakesoft.com/documentation/pxe/ch03.html
> 
> Cheers!

I've tried that before. It is a different PXE implementation other than
the one in RedHat. Anyway, thanks you all. :)

Best regards
Jack

Senior SW Engineer, Intel Corporation.
Intel China Software Lab. 
Tel: 021-52574545 ext. 1306
iNet: 8-752-1306
 
Opinions expressed are those of the author and do not represent Intel
Corporation

