From: Jes Sorensen <jes@sunsite.dk>
Date: Wed, 31 Oct 2001 23:10:42 +0000
Subject: Re: [Linux-ia64] Driver development document
Message-Id: <marc-linux-ia64-105590698805429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805372@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805372@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Doug" = Doug Beattie <dbb@caldera.com> writes:

Doug> FWIW - It may be good, for someone in the real know, to document
Doug> how to modify or write a driver source so it would detect
Doug> whether it was running on ia32 or ia64 or even other type system
Doug> and thereby be able to take advantage of larger memory models.

Doug> From what I understand, many of the current drivers go through
Doug> copydown when used in the ia64 architecture and could be
Doug> improved upon.

There really isn't any need to do so, if you follow the documented
APIs this will work automatically.

Jes

