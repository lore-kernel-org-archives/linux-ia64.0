From: Don Dugger <n0ano@valinux.com>
Date: Tue, 10 Apr 2001 14:16:13 +0000
Subject: Re: [Linux-ia64] 32 bit compatibility on IA-64
Message-Id: <marc-linux-ia64-105590693005388@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005385@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005385@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Josue-

I was hoping nobody would run across this.  The IBM JRE that Oracle
is using is using a horrible interface that is disgustingly specific
to IA32 that I was hoping I could forget about.  Now that you need
it I'll have to implement it for IA64.

As a complete aside, can I ask why are you installing the IA32 Oracle
on your IA64 machine?  I believe that there is an IA64 version available
that might make more sense.

On Mon, Apr 09, 2001 at 10:05:46PM -0700, Josue Amaro wrote:
> All,
> 
> While testing IA-32 compatibility on IA-64 I ran into this problem:
> 
>  Initializing Java
>  Virtual Machine from
> ../stage/Components/oracle.swd.jre/1.1.8/1/DataFiles/Expanded/linux/bin/jre.
> 
> Please wait...
> ldt_clear: modify_ldt: Function not implemented
> ldt_setup: modify_ldt: Function not implemented
> 
> At this point the JRE stops working and exits.
> 
> The Oracle installer runs on IBM's 1.1.8 JRE for Linux (32).
> 
> Regards,
> --
> "When you see the correct course, act; do not wait for orders."
> The Art of War
> 
> ===================================>   Josue Emmanuel Amaro                         Josue.Amaro@oracle.com
>   Linux Products Manager                       Phone:   650.506.1239
>   Intel and Linux Technologies Group           Fax:     650.413.0167
> ===================================> 

Content-Description: Card for Josue Amaro


-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

