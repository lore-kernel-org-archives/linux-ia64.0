From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 19 Jul 2002 16:37:07 +0000
Subject: Re: [Linux-ia64] new problem with memcpy_mck routines
Message-Id: <marc-linux-ia64-105590701905786@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905782@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905782@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've run into this too on the console of the McKinley SDV machines.  A
Control-L cleans it up, but it's really annoying nonetheless.

Jesse

On Thu, Jul 18, 2002 at 08:56:48PM -0600, Alex Williamson wrote:
> 
>    Using the latest memcpy_mck (20020622 + Ken's 7/10 patch) I'm seeing
> problems with screen corruption on VGA.  Here's the test; on a VGA
> console, start vim (colorized syntax highlighting and all), edit a
> large file (several screens).  Scroll down through the file.  You'll
> notice the screen gets corrupted, appears to be columns down the screen
> that scroll faster than others.  I'm using an HP McKinley system and
> have light switched tested by building w/ the old Itanium routines.
> Other apps like less, nvi, etc... don't seem to trigger this.  Thanks,
> 
> 	Alex
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

