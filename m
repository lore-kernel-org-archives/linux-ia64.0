From: Randolph Chung <tausq@debian.org>
Date: Thu, 27 May 2004 15:00:48 +0000
Subject: Re: Linux 2.6.6 link error when removing -O2 compilation flags
Message-Id: <20040527150048.GP7207@tausq.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B601DC.7090508@Ext.Bull.Net>
In-Reply-To: <40B601DC.7090508@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 		I was trying to compile my 2.6.6 linux kernel on an IA64 
> 		machine
> deactivating optimization options (in fact removing "-02" and "-Os" flags
> in Makefile and arch/ia64/Makefile).
> I've done this test with a gcc-2.96, gcc-3.3.3 and gcc-3.4-20040514
> (and removing in this last case "-frename-registers" option).
> Has someone else already encountered such a problem ?

yes, you cannot do that. The kernel relies on some optimizations being
done by the compiler; for example it assumes certain amount of inlining
that happens with optimization enabled.

randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/
