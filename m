From: Grant Grundler <grundler@cup.hp.com>
Date: Mon, 11 Nov 2002 22:02:32 +0000
Subject: Re: [Linux-ia64] RE: +AFs-Linux-ia64+AF0- reader-writer livelock proble
Message-Id: <marc-linux-ia64-105590709805394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805391@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805391@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Van Maren, Kevin" wrote:
> It is also possible that a processor can get stuck +ACI-forever+ACI-
> spinning in the kernel with interrupts disabled trying to
> acquire a lock, and never succeed, without the rest of the
> kernel going south.  If that happens, and application will
> be livelocked, but the rest of the system will function.

Probably not. ia64 systems (and x86 systems with IO xapic) direct
IO interrupts to specific CPUs. Devices would not get serviced
in the above case and IO to/from those devices would come to a
grinding halt. It would look more like "dead" lock than "live" lock.


> It really depends on the particular circumstances.

yes. But it sounds very likely to me.

grant

