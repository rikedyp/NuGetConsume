Foo←{
	⍺⍵ ≠
	Foo←⎕NS⍬
	Foo.bar←{⍵}
	
}