From: David Howells <dhowells@cambridge.redhat.com>
Date: Fri, 08 Nov 2002 17:43:35 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805364@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Do you mean have a separate lock type, or have two different read_lock
> operations on the current type?

You'd probably be better off with separate types... that way you can avoid
problems with conditionals and also with different tracking fields being
required by each grade of lock.

David

