From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 28 Oct 2002 02:08:41 +0000
Subject: Re: [Linux-ia64] NFS on 64
Message-Id: <marc-linux-ia64-105590709805270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805265@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805265@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 27 Oct 2002 16:14:29 -0800, "Jon R. Doyle" <marsaro@interearth.com> said:

  Jon> I am setting up a dozen or so systems that will need to fetch
  Jon> users prefs from a NFS mount point. These will be 32bit
  Jon> servers, but the directory servers where these prefs are will
  Jon> be running Linux on Itanium2. These 64bit servers I intend to
  Jon> export (NFS) out to the 32bit servers; is there anything I
  Jon> should be aware of in this config? Can 32bit systems write to
  Jon> theat NFS export, and compatibility switch or option flags I
  Jon> need to know about?

32 and 64 bit platforms interoperate just fine via NFS.  No special
switches/flags needed.

	--david

