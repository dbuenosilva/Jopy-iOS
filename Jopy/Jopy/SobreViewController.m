//
//  SobreViewController.m
//  Jopy
//
//  Created by Edson Teco on 20/01/15.
//  Copyright (c) 2015 gwaya. All rights reserved.
//

#import "SobreViewController.h"
#import "AppDelegate.h"
#import "Sessao.h"
#import "Pedido+AddOn.h"

@interface SobreViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITextView *txtDetalhes;
@property (weak, nonatomic) IBOutlet UITextView *txtTexto;

@end

@implementation SobreViewController

#pragma mark -
#pragma mark Getters overriders

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

#pragma mark -
#pragma mark Metodos privados

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *versao = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versaoBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    self.txtDetalhes.text = [NSString stringWithFormat:@"Versão %@ (%@)", versao, versaoBundle];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    debug(@"%s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.txtTexto.text = [NSString stringWithFormat:@"Jopy é uma solução para otimizar o trabalho no dia a dia com o sistema de compras da empresa. Por ele é possível aprovar ou rejeitar pedidos a partir de um dispositivo mobile. A atualização dos pedidos é sincronizada com o ERP possibilitando o trabalho de maneira remota. Você pode analisar os pedidos mesmo quando não há conexão com a internet. Os dados analisados ficam armazenados no banco de dados do dispositivo até que seja estabelecida uma conexão com a internet enviando as informações automaticamente. O aplicativo oferece o histórico de pedidos proporcionando análise de compras por fornecedor, produto e/ou centro de custo."];
    
    [self.txtTexto setContentOffset:CGPointZero];
    [self.txtTexto scrollRectToVisible:CGRectZero animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.txtTexto.text = [NSString stringWithFormat:@"Jopy é uma solução para otimizar o trabalho no dia a dia com o sistema de compras da empresa. Por ele é possível aprovar ou rejeitar pedidos a partir de um dispositivo mobile. A atualização dos pedidos é sincronizada com o ERP possibilitando o trabalho de maneira remota. Você pode analisar os pedidos mesmo quando não há conexão com a internet. Os dados analisados ficam armazenados no banco de dados do dispositivo até que seja estabelecida uma conexão com a internet enviando as informações automaticamente. O aplicativo oferece o histórico de pedidos proporcionando análise de compras por fornecedor, produto e/ou centro de custo."];
    
    [self.txtTexto setContentOffset:CGPointZero];
    [self.txtTexto scrollRectToVisible:CGRectZero animated:YES];
}

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark -
#pragma mark Target/Actions

- (IBAction)logoff:(id)sender
{
    [self mostraHudComTexto:@"Saindo..."];
    [Pedido removeTodosOsPedidosInManagedObjectContext:self.appDelegate.managedObjectContext];
    [Sessao efetuaLogoff];
    [self escondeHud];
    [self.appDelegate abreLogin];
}

#pragma mark -
#pragma mark Delegates

#pragma mark -
#pragma mark Notification center

@end
