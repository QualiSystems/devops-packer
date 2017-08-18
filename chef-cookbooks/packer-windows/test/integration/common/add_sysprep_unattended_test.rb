describe file('C:/Windows/Panther/Unattend/unattend.xml') do
	
	it { should exist }

	its('content') { should match(%r{(?m)<LocalAccount.*>.*<Name>kitchen-username</Name>.*</LocalAccount>}) }

	its('content') { should match(%r{(?m)<LocalAccount.*>.*<DisplayName>kitchen-username</DisplayName>.*</LocalAccount>}) }

	its('content') { should match(%r{(?m)<LocalAccount.*>.*<Description>kitchen-user_description</Description>.*</LocalAccount>}) }

	its('content') { should match(%r{(?m)<Password.*>.*<Value>kitchen-password</Value>.*</Password>}) }

	its('content') { should match(%r{<TimeZone>kitchen-time_zone</TimeZone>}) }

	its('content') { should match(%r{<InputLocale>kitchen-locale</InputLocale>}) }

	its('content') { should match(%r{<SystemLocale>kitchen-locale</SystemLocale>}) }	

	its('content') { should match(%r{<UserLocale>kitchen-locale</UserLocale>}) }

	its('content') { should match(%r{<UILanguage>kitchen-locale</UILanguage>}) }
end