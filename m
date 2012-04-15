From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Sun, 15 Apr 2012 21:35:21 +0000
Subject: Re: [regression] Re: [PATCH 2/3] futex: Sanitize cmpxchg_futex_value_locked API
Message-Id: <CAA9xbM5vEyw6wSghJPLdaY3_gfme1scfdYYDe92Rmdg+NitBww@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110307021127.GB31188@google.com>
	<alpine.LFD.2.00.1103082114270.2787@localhost6.localdomain6>
	<20110309112550.GA3050@google.com>
	<alpine.LFD.2.00.1103101948540.2787@localhost6.localdomain6>
	<20110311021654.GA26122@google.com>
	<20110311024851.GC26122@google.com>
	<20120305000112.GA27512@burratino>
	<3908561D78D1C84285E8C5FCA982C28F041A65@ORSMSX104.amr.corp.intel.com>
	<20120305234240.GB1360@burratino>
	<CAA9xbM4iviwVG2VrdEiTom6SueLDviHC+An87ypvQGR1665iwg@mail.gmail.com>
	<CAA9xbM49N7wVkUBBpYNQ+Lwt2WU=axdQ+1gmp5G8N0LR2sxbpA@mail.gmail.com>
In-Reply-To: <CAA9xbM49N7wVkUBBpYNQ+Lwt2WU=axdQ+1gmp5G8N0LR2sxbpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Michel Lespinasse <walken@google.com>, Patrick Baggett <baggett.patrick@gmail.com>, Jakub Jelinek <jakub@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

Patch proposed by Tony in
https://bugzilla.kernel.org/show_bug.cgi?idB757 works for me :-)

Many thanks,

    Emeric



Le 8 mars 2012 22:12, =C9meric Maschino <emeric.maschino@gmail.com> a =E9cr=
it :
> Oops, just to correct myself: the tests described below DON'T return
> gracefully with kernel 3.2. Sorry for the mistake.
>
> =A0 =A0 Emeric
>
>
> Le 8 mars 2012 21:59, =C9meric Maschino <emeric.maschino@gmail.com> a =E9=
crit :
>> ERROR: No such process: FUTEX_CMP_REQUEUE_PI failed
>>
>> For memories, this test passed successfully with 2.6.38-rc8+, with AND
>> without 37a9d912b24f included.
>>
>> Now, adding locked argument, I'm getting:
>>
>> ERROR: Function not implemented: FUTEX_REQUEUE_PI failed
>>
>> Huh? Both these tests nevertheless gracefully return with kernel 3.2,
>> while the second test enters in an unfinite loop with buggy
>> 2.6.38-rc8+.
