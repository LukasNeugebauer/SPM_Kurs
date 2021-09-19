%also stolen from bjoern

spmMain=findobj(groot,'Tag','Graphics');
figure;
plot(spmMain.Children(5).Children.CData(:,1)); % show BOLD of first condition