From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 16 Oct 2002 09:06:30 +0000
Subject: Re: [Linux-ia64] Re: loading a kernel module
Message-Id: <marc-linux-ia64-105590709805173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805162@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805162@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith, Jim,

I found the error in my prog. I wrongly specified brl against a ".global" symbol. Doing brl
against a symbol that is not global does not irritate insmod anymore. For this reason, I do
not need any modification of modutils this time. Sorry for time you spent on this and for
the noise on the list.

Christian


