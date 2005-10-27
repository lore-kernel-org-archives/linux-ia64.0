From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 27 Oct 2005 23:17:33 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <1130455053.17266.30.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-10-28 at 03:05, Khalid Aziz wrote:
> On Thu, 2005-10-27 at 07:21 +0800, Zou Nan hai wrote:
> > 	
> > 	As Tony said, I have my kexec and kexec-tools patches
> > solved those issues. It can boots any unmodified kernel. But they are
> > pending at Intel bureaucracy.
> 
> Can you give us some idea of how you got around the EFI virtualization
> issue?

 I patched the EFI bootparam pointer in purgatory code to an empty dummy
function.

 Zou Nan hai

