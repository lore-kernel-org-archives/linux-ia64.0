From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 25 Nov 2003 18:32:03 +0000
Subject: Re: klibc: type of symbol changed warning
Message-Id: <marc-linux-ia64-106978524206272@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106977774928579@msgid-missing>
In-Reply-To: <marc-linux-ia64-106977774928579@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-11-25 at 12:06, Martin Hicks wrote:
> On Tue, 2003-11-25 at 11:23, Martin Hicks wrote:
> > Hello,
> > 
> > I've been trying to get klibc working on ia64.  I'm running into a
> > problem while compiling it.  I get a warning during the final link:
> 
> 
> Sorry,
> 
> This is what happens while compiling udev against klibc.  The klibc
> seems to work fairly well for most other things contained in the klibc
> tarball (ash, minimal gzip/gunzip, etc)

Adding -nodefaultlibs to LDFLAGS seems to have solved this problem. 
Thanks to willy for giving me the hint that allowed me to figure this
out.

mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296


