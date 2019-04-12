windows_package 'Microsoft OneDrive' do
  action :remove
  returns [0, -2147219820] #-2147219820 is returned when the windows_package tries to uninstall using a path that does not exists (like 'C:\Users\vagrant\AppData\Local\Microsoft\OneDrive\17.3.6816.0313\OneDriveSetup.exe')
end