From: "Gavin Scott" <gavin@allegro.com>
Date: Fri, 15 Nov 2002 17:56:33 +0000
Subject: RE: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805456@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don writes:
> It comes down to engineering trade offs and I still say that the one time
> port will be easier in the long run.

The largest problem is the fuzziness of the "one time".  Customers
performing these migrations are likely to want to run in parallel through
their development and testing processes, and these can take years in
commercial environments.

During this period the issue of data compatibility can be quite important,
especially if they are doing any kid of periodic or real-time replication of
transactions between the old and new environments.

It's (somewhat) easier to migrate binary data for an application if you
don't have to identify all fields and their types in order to byte-juggle
them during conversion.  At least in cases where storage-compatible
compilers and architecture exist.

And then there's the technically-less-relevant but
the-customer-is-always-right issue that many people ask for, or feel better
with, or simply demand, a target system that matches their own personal
endian bigotry[1].

Gavin

[1] For example preferring "big endian" (a.k.a. God's Own Byte Order) over
"little endian" (a.k.a. Satan's Humorous Little Joke)


