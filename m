From: Don Dugger <n0ano@valinux.com>
Date: Tue, 21 Mar 2000 23:15:07 +0000
Subject: Re: [Linux-ia64] gdb support for IA32?
Message-Id: <marc-linux-ia64-105590678204992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204990@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204990@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Vadim-

Funny you should ask.  I've just started to do this.  The ultimate
goal would be to have a single `gdb' that operates on either an
IA64 or IA32 process.  I think that would be a little tricky so
I'm trying to just take the current `gdb' sources, compile them
on my IA64 machine and create a version of `gdb' that only works
on IA32 processes running on IA64.  Assuming I don't run into any
show stopper problems I should have it up and running within about
a week.

On Tue, Mar 21, 2000 at 02:55:49PM -0800, Vadim Furman wrote:
> Are there any plans to support gdb on IA32? 
> If so, when will it be available? 
> 
> Vadim Furman           Mainsoft Corporation    
> vadimf@mainsoft.com    Phone: (408)544-1430
> Fax: (408)544-1444
> 3850 N. First St. 
> San Jose CA. 95134-1702
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


