From: Randolph Chung <randolph@tausq.org>
Date: Fri, 15 Nov 2002 04:47:00 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 2)  I thought PA-RISC was a 32-bit processor which means porting to
> IA64, assuming you're porting to 64-bit addressing (and if not why are
> you porting to IA64 in the first place), will entail data incompatibilities
> independent of endian-ness so you still have to do the data conversion.

this is not true, many (most?) pa20 processors are 64-bit.

randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

