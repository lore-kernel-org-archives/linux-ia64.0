From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Wed, 30 Jan 2002 17:43:28 +0000
Subject: RE: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805963@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is it just an 
> urban myth, or was 
> it once declared upon high that longs shall always be 32 
> bits, ...
I'm not sure it's even an urban myth.  The first (1978) edition of K&R lists
sizes of integral types on some sample hardware.  Longs were 36 bits on a
Honeywell 6000.  Longs have never uniformly been 32 bits.

Hans

