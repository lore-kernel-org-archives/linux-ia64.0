From: Keith Owens <kaos@sgi.com>
Date: Thu, 28 Aug 2003 10:26:29 +0000
Subject: Re: 2.4.21+ Patch for non-identity mapped kernel (SGI SN)
Message-Id: <marc-linux-ia64-106206695911077@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106122911803891@msgid-missing>
In-Reply-To: <marc-linux-ia64-106122911803891@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 27 Aug 2003 17:18:51 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Monday 18 August 2003 11:46 am, Jack Steiner wrote:
>> The changes add support for non-identity mapped kernels. This patch
>> does NOT change the kernel load address - it just adds support for the
>> case where it was loaded into non-identity mapped memory.
>
>I applied this, thanks.

Jack, did you send any 2.4 patches to make MCA/INIT handling work with
non-identity mapped kernels?  If not, I will pull the SGI code and send
it to the list.  Note: the 2.4 SGI code bears little resemblance to the
2.6 LOAD_PHYSICAL() code from Tony Luck, IMHO the 2.6 changes are too
messy to backport.  Unless Tony wants to do that backport ...

