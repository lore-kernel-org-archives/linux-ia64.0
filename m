From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Wed, 01 Sep 2004 16:36:16 +0000
Subject: RE: HCDP concerns
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB007921397@fmsmsx406.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4135A3A7.9000706@bull.net>
In-Reply-To: <4135A3A7.9000706@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> . specifying no "console=" provides no console as the Conout 
>variable is 
>> not exported by EFI at runtime. Should it be ?
>
>I think it makes sense that ConOut should be available for 
>runtime access,
>but I can't point to a reference in the spec.  All the 
>platforms I've seen
>do make it available for runtime access.

Yep, ConOut is one of the globally defined variables that has
visibility in pre-boot space as well as during runtime.  Check
out the attributes for ConOut in section 3.2 of the EFI spec.  

matt
