From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 07 Mar 2001 17:35:13 +0000
Subject: Re: [Linux-ia64] Two questions
Message-Id: <marc-linux-ia64-105590693005257@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005254@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005254@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 07, 2001 at 12:19:05PM +0100, Francis Galiegue wrote:
> 1. Where can I get precise info about firmware revisions, etc etc? I only know
> about what a 'ver' displays at the EFI prompt and what the files in /proc
> display... As to noting the 30+ digit BIOS revision, I do it by hand for now...

Could you explain exactly what do you mean by precise ? version numbers ?
If so, you can get the pal version in  /proc/pal/cpu0/version_info. As for
EFI and SAL, at this point, there is no /proc interface to them. So your
only chance is by dmesg because the kernel prints the versions when it boots.
The rest is probably coming from ACPI, I guess.

-- 
-Stephane

