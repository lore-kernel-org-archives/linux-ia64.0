From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Dec 2002 23:40:16 +0000
Subject: Re: [Linux-ia64] [PATCH] fix /proc/.../vm_info
Message-Id: <marc-linux-ia64-105590709805564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805552@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805552@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 Dec 2002 08:45:37 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> I agree. But I would like a distinction between both UCs
  Christian> like "UC (001)" and "UC (100)".

Actually, it turns out the double UC entry was just plain wrong.  I
wondered about that, but got distracted before I got to double-check
it.  In reality, 001 is reserved for Software Use.  I changed the
table to read:

	"WB",		/* 000 */
	"SW",		/* 001 */
	"010",		/* 010 */
	"011",		/* 011 */
	"UC",		/* 100 */
	"UCE",		/* 101 */
	"WC",		/* 110 */
	"NaTPage"	/* 111 */

Thanks to Jim Hull for catching this.

	--david

