From: jim@tuliptree.org
Date: Mon, 17 Mar 2003 17:34:58 +0000
Subject: RE: [Linux-ia64] question on stabs option being disabled with ia64
Message-Id: <marc-linux-ia64-105590709806142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stabs has fixed size 32-bit fields.  This makes it impossible to express
64-bit addresses unless you change the format, or do something tricky. 
If you change the format, you aren't really emitting stabs anymore.  All
tools would have to be modified to recognize the new format.  That is a
problem we don't really want to deal with.   DWARF2 doesn't have this problem,
and is a better long term choice for other reasons too.

Jim



