From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 21 Oct 2004 14:34:43 +0000
Subject: ia64 implementation of lib/iomap.c
Message-Id: <16759.51459.598187.91726@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is anybody already working on an ia64-version of lib/iomap.c?  If not:
just be aware that as more drivers are starting to use the API, it
becomes increasingly likely that drivers will start to misbehave.  At
least I think that's the case because the default lib/iomap.c makes
some rather arbitrary assumptions about where the I/O ports can live.

	--david
