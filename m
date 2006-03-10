From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 10 Mar 2006 17:29:20 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <200603101729.k2AHTJg04773@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, March 10, 2006 9:12 AM
> Please consider the second issue I mentioned about the "itc":
> Making sure that an external purge request will not be missed by our new
> translation. See also on page 3:127:
> 
> "The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) must occur > before subsequent memory operations. From
a software perspective, this is similar to > acquire semantics. Serialization is still required to observe the side-effects of the >
translation being present."
> 
> How to tell if this "visibility of the itc instruction to generated purges"
> has already been established?
> 
> I think a ";;" is not enough, this is why I propose this sequence:
> 
>     itc.d    r25
>     ;;
>     srlz.d
>     ld8    r18 = [r17]

Thinking wild, I think we need a release semantics on the load.  But such
thing isn't available.

- Ken

