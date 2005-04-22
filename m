From: Horst von Brand <vonbrand@inf.utfsm.cl>
Date: Fri, 22 Apr 2005 03:37:44 +0000
Subject: Re: ia64 git pull
Message-Id: <200504220337.j3M3biAb004521@laptop11.inf.utfsm.cl>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Message from Petr Baudis <pasky@ucw.cz> 
   of "Fri, 22 Apr 2005 00:53:24 +0200." <20050421225324.GA1474@pasky.ji.cz> 
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
In-Reply-To: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Baudis <pasky@ucw.cz>
Cc: tony.luck@intel.com, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Petr Baudis <pasky@ucw.cz> said:

[...]

> The way to work around that is to setup separate rsync URIs for each of
> the trees. ;-) I think I will make git-pasky (Cogito) accept also URIs
> in form
> 
> 	rsync://host/path!branchname
> 
> which will allow you to select the particular branch in the given
> repository, defaulting to the "master" branch.

Please don't use '!', several bash(1) versions just can't seem to get the
fact that '!' is quoted and try to do history expansion all over the place.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
