From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 13 Nov 2007 11:07:25 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <1194952045.12112.30.camel@elijah.suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-c01E2IJpFWPWiiQXesGk"
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
To: linux-ia64@vger.kernel.org


--=-c01E2IJpFWPWiiQXesGk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-11-12 at 16:30 -0800, Roland McGrath wrote:
> [...]
> If you do the artificial test using a long sleep in arch_ptrace_stop,
> then you can probably produce this by hand with gdb.  Have the process
> doing raise(SIGCHLD) or some other harmless signal.  The traced
> process will stop to report the signal to gdb, and then gdb will sit
> at the prompt before resuming it (given "handle SIGFOO stop" if not default).  
> If your sleep is long enough, it won't be hard to get your SIGKILL in there.
> Then when gdb is sitting, the traced process may still be sitting too.
> But it should have gone away instantly from SIGKILL.

I found it extremely difficult to trigger the race condition without the
articifial test - arch_ptrace_stop() only sleeps if the user page is not
present, but in the common case the register stack backing store will
have been quite recently accessed by the process.

It should be possible to create a large file, flush the page cache, put
the RSE into lazy mode, flush it and map the register stack from that
file, so that no memory accesses to the backing store are done before
ptrace_stop(), but for the time being I placed an msleep(100) after
arch_ptrace_stop().

Anyway, I produced a test case which succeeds when the call to
sigkill_pending() is in and fails when it's commented out. I'm attaching
it here (the kernel patch to follow).

Regards,
Petr Tesarik


--=-c01E2IJpFWPWiiQXesGk
Content-Disposition: attachment; filename=kill-race.c
Content-Type: text/x-csrc; name=kill-race.c; charset=UTF-8
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c2lnbmFsLmg+DQojaW5jbHVkZSA8dW5pc3Rk
Lmg+DQojaW5jbHVkZSA8c3lzL3B0cmFjZS5oPg0KI2luY2x1ZGUgPHN5cy93YWl0Lmg+DQojaW5j
bHVkZSA8dGltZS5oPg0KDQojZGVmaW5lIFRFU1RfT0sJCTANCiNkZWZpbmUgVEVTVF9GQUlMRUQJ
MQ0KI2RlZmluZSBURVNUX0FCT1JURUQJMg0KDQojZGVmaW5lIElOVEVSQUNUSVZFCTENCg0Kc3Rh
dGljIGludCBydW5fZGVidWdnZXIocGlkX3QgcGlkKQ0Kew0KCXN0cnVjdCB0aW1lc3BlYyB0bTsN
CglpbnQgc3RhdDsNCglpbnQgcmVzOw0KDQoJcHJpbnRmKCJSdW5uaW5nIGRlYnVnZ2VyIG9uIHBp
ZCAlbGRcbiIsIChsb25nKSBwaWQpOw0KDQoJaWYgKHdhaXRwaWQocGlkLCAmc3RhdCwgMCkgPT0g
LTEpIHsNCgkJcGVycm9yKCJ3YWl0cGlkIGF0dGFjaCIpOw0KCQlnb3RvIGVycm9yX291dDsNCgl9
DQoNCglpZiAocHRyYWNlKFBUUkFDRV9DT05ULCBwaWQsIDAsIDApID09IC0xKSB7DQoJCXBlcnJv
cigiUFRSQUNFX0NPTlQiKTsNCgkJZ290byBlcnJvcl9vdXQ7DQoJfQ0KDQoJdG0udHZfc2VjID0g
MDsNCgl0bS50dl9uc2VjID0gMTAwMDA7DQoJbmFub3NsZWVwKCZ0bSwgTlVMTCk7DQoNCglpZiAo
a2lsbChwaWQsIFNJR0tJTEwpID09IC0xKSB7DQoJCXBlcnJvcigia2lsbCBTSUdLSUxMIik7DQoJ
CWdvdG8gZXJyb3Jfb3V0Ow0KCX0NCg0KI2lmIElOVEVSQUNUSVZFDQoJcHV0cygiU2VudCBTSUdL
SUxMLiBQcmVzcyBFbnRlciB0byBjb250aW51ZS4iKTsNCglnZXRjaGFyKCk7DQojZW5kaWYNCg0K
CWlmICh3YWl0cGlkKHBpZCwgJnN0YXQsIDApID09IC0xKSB7DQoJCXBlcnJvcigid2FpdHBpZCBl
eGl0Iik7DQoJCXJlcyA9IFRFU1RfRkFJTEVEOw0KCX0gZWxzZSBpZiAoV0lGU0lHTkFMRUQoc3Rh
dCkpIHsNCgkJaWYgKFdURVJNU0lHKHN0YXQpICE9IFNJR0tJTEwpIHsNCgkJCWZwcmludGYoc3Rk
ZXJyLCAiQ2hpbGQgdGVybWluYXRlZCBieSBzaWduYWwgJWRcbiIsDQoJCQkJV1RFUk1TSUcoc3Rh
dCkpOw0KCQkJcmVzID0gVEVTVF9GQUlMRUQ7DQoJCX0NCgl9IGVsc2UgaWYgKFdJRlNUT1BQRUQo
c3RhdCkpIHsNCgkJZnByaW50ZihzdGRlcnIsICJDaGlsZCBub3RpZmllZCB1cyBhYm91dCBzaWdu
YWwgJWQgLSBGQUlMRURcbiIsDQoJCQlXU1RPUFNJRyhzdGF0KSk7DQoJCXJlcyA9IFRFU1RfRkFJ
TEVEOw0KCX0gZWxzZSBpZiAoIVdJRkVYSVRFRChzdGF0KSkgew0KCQlmcHJpbnRmKHN0ZGVyciwg
IkNoaWxkIHRlcm1pbmF0ZWQgYWJub3JtYWxseSwgc3RhdD0weCV4XG4iLA0KCQkJc3RhdCk7DQoJ
CXJlcyA9IFRFU1RfRkFJTEVEOw0KCX0gZWxzZSB7DQoJCWZwcmludGYoc3RkZXJyLCAiQ2hpbGQg
ZXhpdGVkIHdpdGggY29kZSAlZFxuIiwNCgkJCVdFWElUU1RBVFVTKHN0YXQpKTsNCgkJcmVzID0g
VEVTVF9GQUlMRUQ7DQoJCWlmIChyZXMgPCBXRVhJVFNUQVRVUyhzdGF0KSkNCgkJCXJlcyA9IFdF
WElUU1RBVFVTKHN0YXQpOw0KCX0NCg0KCXJldHVybiByZXM7DQoNCmVycm9yX291dDoNCglwdHJh
Y2UoUFRSQUNFX0tJTEwsIHBpZCwgMCwgMCk7DQoNCglyZXR1cm4gVEVTVF9BQk9SVEVEOw0KfQ0K
DQpzdGF0aWMgaW50IHJ1bl9jaGlsZCgpDQp7DQoJLyogQXR0YWNoIG91cnNlbHZlcyAqLw0KCWlm
IChwdHJhY2UoUFRSQUNFX1RSQUNFTUUsIDAsIDAsIDApID09IC0xKSB7DQoJCXBlcnJvcigiVFJB
Q0VfTUUiKTsNCgkJcmV0dXJuIFRFU1RfQUJPUlRFRDsNCgl9DQoNCglmb3IgKDs7KQ0KCQlyYWlz
ZShTSUdDSExEKTsNCn0NCg0KaW50IG1haW4oKQ0Kew0KCXBpZF90IHBpZDsNCg0KCWlmICgocGlk
ID0gZm9yaygpKSkNCgkJcmV0dXJuIHJ1bl9kZWJ1Z2dlcihwaWQpOw0KCWVsc2UNCgkJcmV0dXJu
IHJ1bl9jaGlsZCgpOw0KfQ0K


--=-c01E2IJpFWPWiiQXesGk--
